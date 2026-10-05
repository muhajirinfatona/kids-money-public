create or replace function public.record_transaction(
  p_child_id uuid,
  p_type text,
  p_amount numeric,
  p_wallet_type text,
  p_description text
) returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  current_balance numeric;
begin
  if not public.owns_child(p_child_id) then
    raise exception 'child_not_owned';
  end if;
  if p_type not in ('income', 'expense') then
    raise exception 'invalid_transaction_type';
  end if;
  if p_wallet_type not in ('spend', 'save', 'share') then
    raise exception 'invalid_wallet_type';
  end if;
  if p_amount is null or p_amount <= 0 then
    raise exception 'invalid_amount';
  end if;
  select balance into current_balance
    from public.wallets
    where child_id = p_child_id and wallet_type = p_wallet_type
    for update;
  if current_balance is null then
    raise exception 'wallet_not_found';
  end if;
  if p_type = 'expense' and current_balance < p_amount then
    raise exception 'insufficient_balance';
  end if;
  insert into public.transactions(child_id, type, amount, wallet_type, category, description)
    values (p_child_id, p_type, p_amount, p_wallet_type, 'other', left(trim(p_description), 240));
  update public.wallets
    set balance = current_balance + case when p_type = 'income' then p_amount else -p_amount end,
        updated_at = now()
    where child_id = p_child_id and wallet_type = p_wallet_type;
end;
$$;

revoke all on function public.record_transaction(uuid, text, numeric, text, text) from public;
grant execute on function public.record_transaction(uuid, text, numeric, text, text) to authenticated;
