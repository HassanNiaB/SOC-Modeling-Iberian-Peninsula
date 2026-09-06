# 04_scenario_prediction.R
# ============================================================
# پیش‌بینی SOC برای سناریوهای اقلیمی آینده
# ============================================================

source(here("scripts", "00_config.R"))

# بارگذاری مدل‌های آموزش‌دیده
rf_model     <- readRDS(file.path(out_models, "rf_model.rds"))
xgb_model    <- readRDS(file.path(out_models, "xgb_model.rds"))
cubist_model <- readRDS(file.path(out_models, "cubist_model.rds"))
svm_model    <- readRDS(file.path(out_models, "svm_model.rds"))
dt_model     <- readRDS(file.path(out_models, "dt_model.rds"))

# بارگذاری وزن‌های بهینه
weights_df <- read.csv(file.path(out_pred, "ensemble_weights.csv"))
weights <- weights_df$Weight
names(weights) <- weights_df$Model

# بارگذاری داده‌های سناریو
scenario <- read.csv(file.path(data_raw, "Scenario.csv"))

predictors <- c("TH_LAT", "Elev", "ec1", "EVI250", "t58560", "slope250",
                "twi", "pr58060", "TH_LONG", "susm")

cat("🔮 Predicting for future scenario (SSP585)...\n")

# پیش‌بینی با هر مدل
pred_rf_scenario     <- predict(rf_model, newdata = scenario)
pred_xgb_scenario    <- predict(xgb_model, newdata = scenario)
pred_cubist_scenario <- predict(cubist_model, newdata = scenario)
pred_svm_scenario    <- predict(svm_model, newdata = scenario)
pred_dt_scenario     <- predict(dt_model, newdata = scenario)

# ترکیب با وزن‌های ensemble
predictions_matrix <- cbind(
  RF = pred_rf_scenario,
  XGBoost = pred_xgb_scenario,
  Cubist = pred_cubist_scenario,
  SVM = pred_svm_scenario,
  DT = pred_dt_scenario
)

ens_pred_scenario <- as.matrix(predictions_matrix) %*% weights

# ذخیره نتایج
scenario_results <- data.frame(
  POINTID = scenario$POINTID,
  SOC_Future = as.numeric(ens_pred_scenario)
)

write.csv(scenario_results, 
          file.path(out_pred, "scenario_SSP585_predictions.csv"), 
          row.names = FALSE)

cat("✅ Scenario predictions saved!\n")
cat("📁 File:", file.path(out_pred, "scenario_SSP585_predictions.csv"), "\n")

# ============================================================
# همچنین پیش‌بینی‌های هر مدل پایه را ذخیره می‌کنیم
# ============================================================
base_scenario_preds <- data.frame(
  POINTID = scenario$POINTID,
  RF = pred_rf_scenario,
  XGBoost = pred_xgb_scenario,
  Cubist = pred_cubist_scenario,
  SVM = pred_svm_scenario,
  DT = pred_dt_scenario
)

write.csv(base_scenario_preds, 
          file.path(out_pred, "base_models_scenario_preds.csv"), 
          row.names = FALSE)

cat("✅ All scenario predictions saved!\n")
