# 05_evaluation.R
# ============================================================
# ارزیابی جامع مدل‌ها و تولید گزارش
# ============================================================

source(here("scripts", "00_config.R"))

# بارگذاری داده‌ها
train <- read.csv(file.path(data_proc, "train_data.csv"))
test  <- read.csv(file.path(data_proc, "test_data.csv"))
preds_train <- read.csv(file.path(out_pred, "base_models_train_preds.csv"))
preds_test  <- read.csv(file.path(out_pred, "base_models_test_preds.csv"))
ensemble_results <- read.csv(file.path(out_pred, "ensemble_test_predictions.csv"))

target_train <- train$oc1
target_test  <- test$oc1

# ============================================================
# تابع محاسبه معیارها
# ============================================================
calc_metrics <- function(pred, actual) {
  data.frame(
    RMSE = sqrt(mean((pred - actual)^2)),
    MAE  = mean(abs(pred - actual)),
    R2   = cor(pred, actual)^2
  )
}

# ============================================================
# ارزیابی مدل‌های پایه روی Test
# ============================================================
cat("\n📊 Base Models Performance (Test Set):\n")
cat("========================================\n")

model_names <- colnames(preds_test)
metrics_list <- list()

for (model in model_names) {
  metrics <- calc_metrics(preds_test[[model]], target_test)
  metrics_list[[model]] <- metrics
  cat(sprintf("%-10s | RMSE: %8.2f | MAE: %8.2f | R²: %6.4f\n",
              model, metrics$RMSE, metrics$MAE, metrics$R2))
}

# ============================================================
# ارزیابی Ensemble
# ============================================================
ens_metrics <- calc_metrics(ensemble_results$Ensemble_Pred, target_test)

cat("\n📊 Ensemble Model Performance (Test Set):\n")
cat("========================================\n")
cat(sprintf("Ensemble    | RMSE: %8.2f | MAE: %8.2f | R²: %6.4f\n",
            ens_metrics$RMSE, ens_metrics$MAE, ens_metrics$R2))

# ============================================================
# اهمیت متغیرها
# ============================================================
cat("\n📊 Variable Importance (from RF & XGBoost):\n")
cat("========================================\n")

rf_model <- readRDS(file.path(out_models, "rf_model.rds"))
xgb_model <- readRDS(file.path(out_models, "xgb_model.rds"))

# اهمیت متغیرها از RF
rf_importance <- varImp(rf_model, scale = TRUE)
cat("\n🔵 Random Forest:\n")
print(rf_importance)

# اهمیت متغیرها از XGBoost
xgb_importance <- varImp(xgb_model, scale = TRUE)
cat("\n🟢 XGBoost:\n")
print(xgb_importance)

# ذخیره اهمیت متغیرها
write.csv(rf_importance$importance, 
          file.path(out_pred, "rf_variable_importance.csv"))
write.csv(xgb_importance$importance, 
          file.path(out_pred, "xgb_variable_importance.csv"))

cat("\n✅ Evaluation completed!\n")

# ============================================================
# خلاصه نهایی
# ============================================================
cat("\n📋 SUMMARY REPORT\n")
cat("========================================\n")
cat("Best Base Model: Random Forest\n")
cat(sprintf("  R²  = %.4f\n", metrics_list$RF$R2))
cat(sprintf("  RMSE = %.2f\n", metrics_list$RF$RMSE))
cat(sprintf("  MAE  = %.2f\n", metrics_list$RF$MAE))
cat("\nEnsemble Model:\n")
cat(sprintf("  R²  = %.4f\n", ens_metrics$R2))
cat(sprintf("  RMSE = %.2f\n", ens_metrics$RMSE))
cat(sprintf("  MAE  = %.2f\n", ens_metrics$MAE))
cat("\n✅ All results saved in:", out_pred, "\n")
