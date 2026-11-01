test_that("split_ucalitems splits items across midnight properly", {
  # 2021-06-01 22:00:00 US/Central = 1622584800000 ms
  # 2021-06-02 02:00:00 US/Central = 1622599200000 ms (total 4 hrs: 2 hrs on 2021-06-01, 2 hrs on 2021-06-02)
  # 2021-06-02 10:00:00 US/Central = 1622628000000 ms
  # 2021-06-02 11:00:00 US/Central = 1622631600000 ms (total 1 hr on 2021-06-02)

  test_data <- data.table::data.table(
    user_id = c("user1", "user1"),
    cal_item_id = c(1L, 2L),
    start_timestamp = c(1622584800000, 1622628000000),
    end_timestamp = c(1622599200000, 1622631600000),
    type_decoded = c("ACTIVITY", "ACTIVITY"),
    subtype_decoded = c("HOME", "WORKPLACE"),
    distance = c(0, 0),
    confirm_timestamp = c(0, 0),
    edit_timestamp = c(0, 0)
  )

  split_res <- split_ucalitems(test_data, local_timezone = "US/Central", day_start_hour = 0)

  # Should produce 3 rows: item 1 split into 2 rows, item 2 in 1 row
  expect_equal(nrow(split_res), 3L)
  expect_equal(split_res$start_date, as.Date(c("2021-06-01", "2021-06-02", "2021-06-02")))
  expect_equal(round(split_res$duration_after_split, 2), c(2, 2, 1))
  expect_equal(split_res$dow, c("Tuesday", "Wednesday", "Wednesday"))
})

test_that("split_ucalitems handles items spanning three days", {
  # 2021-06-01 20:00:00 US/Central = 1622577600000 ms
  # 2021-06-03 04:00:00 US/Central = 1622692800000 ms (total 32 hrs: 4 hrs day 1, 24 hrs day 2, 4 hrs day 3)
  test_data <- data.table::data.table(
    user_id = "user1",
    cal_item_id = 1L,
    start_timestamp = 1622577600000,
    end_timestamp = 1622692800000,
    type_decoded = "ACTIVITY",
    subtype_decoded = "HOME",
    distance = 0,
    confirm_timestamp = 0,
    edit_timestamp = 0
  )

  split_res <- split_ucalitems(test_data, local_timezone = "US/Central", day_start_hour = 0)

  expect_equal(nrow(split_res), 3L)
  expect_equal(split_res$start_date, as.Date(c("2021-06-01", "2021-06-02", "2021-06-03")))
  expect_equal(round(split_res$duration_after_split, 2), c(4, 24, 4))
})
