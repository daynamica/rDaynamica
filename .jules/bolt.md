## 2025-05-18 - Vectorizing multi-day date sequence generation in data.table
**Learning:** Using `lapply(split(dt, by = 'id'), ...)` to expand date sequences for each record creates thousands of single-row `data.table`s, causing severe allocation and partitioning overhead.
**Action:** Use `sequence(dt$days) - 1L` combined with `rep(dt$start_date, dt$days) + day_offsets` to generate date sequence tables in a single vectorized data.table operation.

## 2026-11-01 - Memoizing regex parsing across unique survey response strings
**Learning:** Survey tables often contain tens of thousands of rows with only a few hundred unique response text values. Calling regex `strsplit` with lookarounds and `lapply` per row wastes over 95% of execution time on duplicate strings.
**Action:** Deduplicate response values with `u <- unique(response)`, execute expensive regex splitting on `u`, and project back using `u_result[match(response, u)]`.
