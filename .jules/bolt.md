## 2025-05-18 - Vectorized multi-day sequence expansion over data.table split/lapply/rbindlist

**Learning:** Splitting a `data.table` by a unique identifier (`split(dt, by = 'id')`) when there are tens of thousands of rows allocates tens of thousands of tiny `data.table` chunks. Iterating over them with `lapply` and rebinding with `rbindlist` takes >11 seconds for ~18k rows. Expanding day sequences vectorially using `rep(id, days)` and adding `sequence(days) - 1L` day offsets to `rep(start_date, days)` creates the exact same lookup table in ~6 milliseconds (>1,000x faster, reducing overall function runtime by >10x).

**Action:** Whenever generating date sequences or integer ranges per record in tabular R pipelines, use vectorized `rep()` and `sequence()` instead of `split() + lapply(seq.Date) + rbindlist()`.
