# 00_config.R
# ============================================================
# تنظیمات اولیه، کتابخانه‌ها و مسیرهای نسبی
# ============================================================

if (!require(here)) install.packages("here")
library(here)

data_raw   <- here("data", "raw")
data_proc  <- here("data", "processed")
out_models <- here("outputs", "models")
out_pred   <- here("outputs", "predictions")
out_figs   <- here("outputs", "figures")

dir.create(data_raw,   showWarnings = FALSE, recursive = TRUE)
dir.create(data_proc,  showWarnings = FALSE, recursive = TRUE)
dir.create(out_models, showWarnings = FALSE, recursive = TRUE)
dir.create(out_pred,   showWarnings = FALSE, recursive = TRUE)
dir.create(out_figs,   showWarnings = FALSE, recursive = TRUE)

packages <- c("caret", "xgboost", "randomForest", "e1071", 
              "Cubist", "ranger", "rpart", "here")

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  }
}

set.seed(123)
cat("✅ Configuration loaded successfully!\n")
