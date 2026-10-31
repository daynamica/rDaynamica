test_that("split_ucalitems correctly splits single-day and multi-day items across midnight", {
  # 1. Single day item: starts 10:00, ends 12:00 on 2024-01-01
  # 2. Multi-day item spanning 3 calendar days: starts 2024-01-01 22:00, ends 2024-01-03 04:00 (duration: 30 hours)
  start_dt_1 <- as.POSIXct("2024-01-01 10:00:00", tz = "UTC")
  end_dt_1   <- as.POSIXct("2024-01-01 12:00:00", tz = "UTC")

  start_dt_2 <- as.POSIXct("2024-01-01 22:00:00", tz = "UTC")
  end_dt_2   <- as.POSIXct("2024-01-03 04:00:00", tz = "UTC")

  items <- data.table::data.table(
    user_id = c("user_1", "user_1"),
    cal_item_id = c(1L, 2L),
    start_timestamp = as.numeric(c(start_dt_1, start_dt_2)) * 1000,
    end_timestamp = as.numeric(c(end_dt_1, end_dt_2)) * 1000,
    confirm_timestamp = c(100, 0),
    edit_timestamp = c(0, 0),
    distance = c(5, 30),
    type_decoded = c("TRIP", "ACTIVITY"),
    subtype_decoded = c("CAR - DRIVER", "HOME"),
    survey_not_null = c(FALSE, TRUE)
  )

  split_res <- split_ucalitems(
    items,
    local_timezone = "UTC",
    day_start_hour = 0,
    min_time_stamp = 0
  )

  # Item 1 has 1 record, Item 2 spans 3 days (Jan 1, Jan 2, Jan 3) -> total 4 records
  expect_equal(nrow(split_res), 4)

  # Check total duration is preserved: 2h + 30h = 32 hours
  expect_equal(sum(split_res$duration_after_split), 32)

  # Check total distance is preserved: 5 + 30 = 35
  expect_equal(sum(split_res$distance_after_split), 35)

  # Check split for item 2:
  # Part 1: Jan 1 22:00 to Jan 2 00:00 = 2 hours, distance = 30 * 2 / 30 = 2
  # Part 2: Jan 2 00:00 to Jan 3 00:00 = 24 hours, distance = 30 * 24 / 30 = 24
  # Part 3: Jan 3 00:00 to Jan 3 04:00 = 4 hours, distance = 30 * 4 / 30 = 4
  item2_splits <- split_res[cal_item_id == 2L]
  expect_equal(nrow(item2_splits), 3)
  expect_equal(item2_splits$duration_after_split, c(2, 24, 4))
  expect_equal(item2_splits$distance_after_split, c(2, 24, 4))
  expect_equal(as.character(item2_splits$start_date), c("2024-01-01", "2024-01-02", "2024-01-03"))
})
