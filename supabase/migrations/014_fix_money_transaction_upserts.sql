-- Fix generated money-ledger upserts against the partial unique index
-- transactions_source_idx ON transactions(source, source_id)
-- WHERE source_id IS NOT NULL.

CREATE OR REPLACE FUNCTION public.sync_purchase_transaction()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_materials_cat_id UUID;
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE public.transactions
      SET deleted_at = COALESCE(deleted_at, NOW())
    WHERE source = 'purchase' AND source_id = OLD.id;
    RETURN OLD;
  END IF;

  IF NEW.deleted_at IS NOT NULL THEN
    UPDATE public.transactions
      SET deleted_at = COALESCE(NEW.deleted_at, NOW())
    WHERE source = 'purchase' AND source_id = NEW.id;
    RETURN NEW;
  END IF;

  SELECT id INTO v_materials_cat_id
  FROM public.categories WHERE name = 'Materials' LIMIT 1;

  IF v_materials_cat_id IS NULL THEN
    RAISE EXCEPTION 'Materials transaction category is missing';
  END IF;

  INSERT INTO public.transactions (
    project_id, date, type, category_id, description, amount, source, source_id, created_by
  )
  VALUES (
    NEW.project_id, NEW.date, 'expense', v_materials_cat_id,
    NEW.item, NEW.amount, 'purchase', NEW.id, NEW.created_by
  )
  ON CONFLICT (source, source_id) WHERE source_id IS NOT NULL
  DO UPDATE SET
    project_id = EXCLUDED.project_id,
    date = EXCLUDED.date,
    category_id = EXCLUDED.category_id,
    description = EXCLUDED.description,
    amount = EXCLUDED.amount,
    deleted_at = NULL,
    updated_at = NOW();

  RETURN NEW;
END;
$function$;

CREATE OR REPLACE FUNCTION public.mark_period_paid()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_wages_cat_id UUID;
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.attendance SET locked = TRUE
    WHERE labour_id = NEW.labour_id
      AND project_id = NEW.project_id
      AND date BETWEEN NEW.period_start AND NEW.period_end
      AND status = 'present';

    SELECT id INTO v_wages_cat_id
    FROM public.categories WHERE name = 'Labour Wages' LIMIT 1;

    IF NEW.net > 0 THEN
      IF v_wages_cat_id IS NULL THEN
        RAISE EXCEPTION 'Labour Wages transaction category is missing';
      END IF;

      INSERT INTO public.transactions (
        project_id, date, type, category_id, description, amount, source, source_id, created_by
      )
      VALUES (
        NEW.project_id, NEW.paid_on, 'expense', v_wages_cat_id,
        'Net wage payment: ' || NEW.period_start || ' to ' || NEW.period_end,
        NEW.net, 'wage', NEW.id, NEW.created_by
      )
      ON CONFLICT (source, source_id) WHERE source_id IS NOT NULL
      DO UPDATE SET
        amount = EXCLUDED.amount,
        date = EXCLUDED.date,
        description = EXCLUDED.description,
        deleted_at = NULL,
        updated_at = NOW();
    END IF;
  ELSIF TG_OP = 'UPDATE' AND OLD.deleted_at IS DISTINCT FROM NEW.deleted_at THEN
    IF NEW.deleted_at IS NOT NULL THEN
      UPDATE public.attendance SET locked = FALSE
      WHERE labour_id = NEW.labour_id
        AND project_id = NEW.project_id
        AND date BETWEEN NEW.period_start AND NEW.period_end;

      UPDATE public.transactions SET deleted_at = NOW()
      WHERE source = 'wage' AND source_id = NEW.id;
    ELSE
      UPDATE public.attendance SET locked = TRUE
      WHERE labour_id = NEW.labour_id
        AND project_id = NEW.project_id
        AND date BETWEEN NEW.period_start AND NEW.period_end
        AND status = 'present';

      UPDATE public.transactions SET deleted_at = NULL
      WHERE source = 'wage' AND source_id = NEW.id;
    END IF;
  END IF;

  RETURN NEW;
END;
$function$;
