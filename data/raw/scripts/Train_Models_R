# 02_train_models.R
# ============================================================
# آموزش ۵ مدل پایه: RF, XGBoost, Cubist, SVM, DT
# ============================================================

source(here("scripts", "00_config.R"))

# بارگذاری داده‌های تقسیم‌شده
train <- read.csv(file.path(data_proc, "train_data.csv"))
test  <- read.csv(file.path(data_proc, "test_data.csv"))

predictors <- c("TH_LAT", "Elev", "ec1", "EVI250", "t58560", "slope250",
                "twi", "pr58060", "TH_LONG", "susm")
target <- "oc1"

# تنظیمات cross-validation یکسان برای همه مدل‌ها
control <- trainControl(method = "repeatedcv", 
                        number = 10, 
                        repeats = 5,
                        verboseIter = FALSE)

cat("🚀 Starting model training...\n")

# ============================================================
# 1. Random Forest (RF)
# ============================================================
cat("\n📌 Training Random Forest...\n")

rf_grid <- expand.grid(
  mtry = 1:10,
  splitrule = c("extratrees", "gini"),
  min.node.size = c(1, 5, 10, 15, 20)
)

rf_model <- train(
  x = train[, predictors],
  y = train[, target],
  method = "ranger",
  trControl = control,
  tuneGrid = rf_grid,
  metric = "RMSE",
  importance = "impurity",
  num.trees = 500
)

saveRDS(rf_model, file.path(out_models, "rf_model.rds"))
pred_rf_train <- predict(rf_model, train)
pred_rf_test  <- predict(rf_model, test)

cat("✅ RF training completed\n")

# ============================================================
# 2. XGBoost
# ============================================================
cat("\n📌 Training XGBoost...\n")

xgb_grid <- expand.grid(
  nrounds = c(20, 30, 50),
  max_depth = c(3, 5, 7),
  eta = c(0.01, 0.05, 0.1),
  gamma = c(0.01, 0.05, 0.1),
  colsample_bytree = c(0.6, 0.8, 1),
  min_child_weight = c(1, 3, 5),
  subsample = c(0.6, 0.8, 1)
)

xgb_model <- train(
  x = train[, predictors],
  y = train[, target],
  method = "xgbTree",
  trControl = control,
  tuneGrid = xgb_grid,
  metric = "RMSE",
  verbose = FALSE
)

saveRDS(xgb_model, file.path(out_models, "xgb_model.rds"))
pred_xgb_train <- predict(xgb_model, train)
pred_xgb_test  <- predict(xgb_model, test)

cat("✅ XGBoost training completed\n")

# ============================================================
# 3. Cubist
# ============================================================
cat("\n📌 Training Cubist...\n")

cubist_grid <- expand.grid(
  committees = c(1, 10, 20, 50, 93),
  neighbors = c(0, 3, 5, 7, 9)
)

cubist_model <- train(
  x = train[, predictors],
  y = train[, target],
  method = "cubist",
  trControl = control,
  tuneGrid = cubist_grid,
  metric = "RMSE"
)

saveRDS(cubist_model, file.path(out_models, "cubist_model.rds"))
pred_cubist_train <- predict(cubist_model, train)
pred_cubist_test  <- predict(cubist_model, test)

cat("✅ Cubist training completed\n")

# ============================================================
# 4. Support Vector Machine (SVM)
# ============================================================
cat("\n📌 Training SVM...\n")

svm_grid <- expand.grid(
  C = 2^(-5:5),
  sigma = 2^(-5:5)
)

svm_model <- train(
  x = train[, predictors],
  y = train[, target],
  method = "svmRadial",
  preProcess = c("center", "scale"),
  trControl = control,
  tuneGrid = svm_grid,
  metric = "RMSE"
)

saveRDS(svm_model, file.path(out_models, "svm_model.rds"))
pred_svm_train <- predict(svm_model, train)
pred_svm_test  <- predict(svm_model, test)

cat("✅ SVM training completed\n")

# ============================================================
# 5. Decision Tree (DT)
# ============================================================
cat("\n📌 Training Decision Tree...\n")

dt_grid <- expand.grid(cp = seq(0.01, 0.5, length.out = 20))

dt_model <- train(
  x = train[, predictors],
  y = train[, target],
  method = "rpart",
  trControl = control,
  tuneGrid = dt_grid,
  metric = "RMSE"
)

saveRDS(dt_model, file.path(out_models, "dt_model.rds"))
pred_dt_train <- predict(dt_model, train)
pred_dt_test  <- predict(dt_model, test)

cat("✅ DT training completed\n")

# ============================================================
# ذخیره پیش‌بینی‌ها برای Ensemble
# ============================================================
preds_train <- data.frame(
  RF = pred_rf_train,
  XGBoost = pred_xgb_train,
  Cubist = pred_cubist_train,
  SVM = pred_svm_train,
  DT = pred_dt_train
)

preds_test <- data.frame(
  RF = pred_rf_test,
  XGBoost = pred_xgb_test,
  Cubist = pred_cubist_test,
  SVM = pred_svm_test,
  DT = pred_dt_test
)

write.csv(preds_train, file.path(out_pred, "base_models_train_preds.csv"), row.names = FALSE)
write.csv(preds_test, file.path(out_pred, "base_models_test_preds.csv"), row.names = FALSE)

cat("\n✅ All models trained and predictions saved!\n")
cat("📁 Predictions saved in:", out_pred, "\n")
