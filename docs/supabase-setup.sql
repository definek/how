-- 야간매출 계산기 · Supabase 준비 SQL
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 Run 하면 됩니다.

create table if not exists public.sales (
  id            text        primary key,
  sale_date     date        not null,
  weekly        bigint      not null default 0,   -- 주간매출 (입력값)
  current_total bigint      not null default 0,   -- 현재매출 (입력값)
  saved_at      timestamptz not null default now()
);

-- 날짜순 조회를 자주 하므로 인덱스를 하나 둔다.
create index if not exists sales_date_idx on public.sales (sale_date desc);

alter table public.sales enable row level security;

-- 앱은 anon key 하나로만 접근한다. 키를 가진 쪽에 읽기·쓰기를 모두 허용한다.
-- 주의: 이 정책은 anon key를 아는 사람이면 누구나 이 표를 읽고 쓸 수 있다는 뜻이다.
--       그래서 키를 저장소나 페이지에 넣지 않고, 앱 안에서 직접 입력받아
--       기기에만 보관한다. 더 엄격하게 막으려면 아래 '로그인 방식' 주석을 참고.
drop policy if exists "anon full access" on public.sales;
create policy "anon full access" on public.sales
  for all
  to anon
  using (true)
  with check (true);

-- ── 로그인 방식으로 더 엄격하게 막고 싶다면 ──────────────────────────
-- 1) 위 정책을 지우고, 사용자 구분용 열을 추가한다.
--      alter table public.sales add column user_id uuid default auth.uid();
-- 2) 본인 기록만 보이도록 정책을 바꾼다.
--      create policy "own rows" on public.sales
--        for all to authenticated
--        using (user_id = auth.uid())
--        with check (user_id = auth.uid());
-- 3) 앱에 Supabase 로그인 화면을 붙여야 하므로 코드 수정이 함께 필요하다.
