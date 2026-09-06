# 03_ensemble.R
# ============================================================
# ایجاد Ensemble با وزن‌دهی بهینه (Weighted Averaging)
# ============================================================

source(here("scripts", "00_config.R"))

# بارگذاری پیش‌بینی‌های مدل‌های پایه
preds_train <- read.csv(file.path(out_pred, "base_models_train_preds.csv"))
preds_test  <- read.csv(file.path(out_pred, "base_models_test_preds.csv"))

# بارگذاری داده‌های اصلی برای مقادیر واقعی
train <- read.csv(file.path(data_proc, "train_data.csv"))
test  <- read.csv(file.path(data_proc, "test_data.csv"))

target_train <- train$oc1
target_test  <- test$oc1

# ============================================================
# محاسبه RMSE هر مدل روی Training Set
# ============================================================
rmse_models <- apply(preds_train, 2, function(p) {
  sqrt(mean((p - target_train)^2))
})

# وزن‌های اولیه (معکوس RMSE)
weights_init <- 1 / rmse_models
weights_init <- weights_init / sum(weights_init)

cat("📊 Initial weights (based on RMSE):\n")
print(round(weights_init, 4))

# ============================================================
# بهینه‌سازی وزن‌ها با ۱۰۰۰ تکرار (جستجوی تصادفی)
# ============================================================
set.seed(123)
best_weights <- weights_init
best_rmse <- sqrt(mean((as.matrix(preds_train) %*% weights_init - target_train)^2))

cat("\n🔍 Optimizing weights with 1000 iterations...\n")

for (i in 1:1000) {
  # ضریب تصادفی بین 0.5 تا 1.5 برای هر وزن
  factor <- runif(5, min = 0.5, max = 1.5)
  w <- weights_init * factor
  w <- w / sum(w)  # نرمال‌سازی
  
  # محاسبه RMSE روی Training
  ens_pred <- as.matrix(preds_train) %*% w
  rmse_val <- sqrt(mean((ens_pred - target_train)^2))
  
  if (rmse_val < best_rmse) {
    best_rmse <- rmse_val
    best_weights <- w
  }
  
  # نمایش پیشرفت هر ۱۰۰ تکرار
  if (i %% 100 == 0) {
    cat("  Iteration", i, "- Best RMSE so far:", round(best_rmse, 2), "\n")
  }
}

# ============================================================
# ارزیابی Ensemble روی Test Set
# ============================================================
ens_pred_test <- as.matrix(preds_test) %*% best_weights

rmse_ens <- sqrt(mean((ens_pred_test - target_test)^2))
mae_ens  <- mean(abs(ens_pred_test - target_test))
r2_ens   <- cor(ens_pred_test, target_test)^2

cat("\n✅ Ensemble Results (Test Set):\n")
cat("  RMSE:", round(rmse_ens, 2), "\n")
cat("  MAE :", round(mae_ens, 2), "\n")
cat("  R²  :", round(r2_ens, 4), "\n")

cat("\n📊 Optimal weights:\n")
names(best_weights) <- colnames(preds_train)
print(round(best_weights, 4))

# ============================================================
# ذخیره نتایج
# ============================================================
weights_df <- data.frame(
  Model = names(best_weights),
  Weight = best_weights
)
write.csv(weights_df, file.path(out_pred, "ensemble_weights.csv"), row.names = FALSE)

ensemble_results <- data.frame(
  POINTID = test$POINTID,
  Actual_SOC = target_test,
  Ensemble_Pred = as.numeric(ens_pred_test)
)
write.csv(ensemble_results, file.path(out_pred, "ensemble_test_predictions.csv"), row.names = FALSE)

cat("\n✅ Ensemble completed!\n")
cat("📁 Results saved in:", out_pred, "\n")
