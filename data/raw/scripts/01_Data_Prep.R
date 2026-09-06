# 01_data_prep.R
# ============================================================
# بارگذاری داده و تقسیم به Train/Test
# ============================================================

source(here("scripts", "00_config.R"))

data <- read.csv(file.path(data_raw, "Scenario.csv"))

predictors <- c("TH_LAT", "Elev", "ec1", "EVI250", "t58560", "slope250",
                "twi", "pr58060", "TH_LONG", "susm")
target <- "oc1"

data_complete <- na.omit(data[, c(predictors, target)])

trainIndex <- createDataPartition(data_complete[, target], p = 0.7, list = FALSE)
train <- data_complete[trainIndex, ]
test  <- data_complete[-trainIndex, ]

write.csv(train, file.path(data_proc, "train_data.csv"), row.names = FALSE)
write.csv(test, file.path(data_proc, "test_data.csv"), row.names = FALSE)

cat("✅ Data preparation completed!\n")
