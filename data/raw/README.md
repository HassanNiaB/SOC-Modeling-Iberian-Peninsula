# Modeling Soil Organic Carbon under Climate Change Using a Heterogeneous Ensemble Machine Learning Approach

## Overview

This repository contains the R-based machine-learning workflow developed for the study:

**Modeling Soil Organic Carbon under Climate Change Scenario Using a Heterogeneous Ensemble Machine Learning Approach: A Case Study in Portugal and Spain**

The study develops a digital soil mapping framework for predicting Soil Organic Carbon (SOC) across the Iberian Peninsula and investigates potential future SOC changes under the SSP585 climate-change scenario.

The workflow integrates five heterogeneous machine-learning algorithms:

1. Random Forest (RF)
2. Extreme Gradient Boosting (XGBoost)
3. Support Vector Regression (SVR)
4. Cubist
5. Decision Tree (DT)

The predictions of the five base learners are subsequently combined using a weighted heterogeneous ensemble.

---

## Study Area

The study covers Portugal and Spain in the Iberian Peninsula.

The study region represents a geographically and environmentally heterogeneous area characterized by substantial variation in climate, terrain, vegetation, soil conditions, and land use.

---

## Data

The target variable is Soil Organic Carbon (SOC), represented by the `oc1` variable.

The modelling dataset contains environmental predictors representing climate, terrain, vegetation, soil properties, and geographic location.

The predictor variables used in the machine-learning models are:

- `TH_LAT` — Latitude
- `Elev` — Elevation
- `ec1` — Soil electrical conductivity
- `EVI250` — Enhanced Vegetation Index
- `t58560` — Temperature
- `slope250` — Slope
- `twi` — Topographic Wetness Index
- `pr58060` — Precipitation
- `TH_LONG` — Longitude
- `susm` — Surface soil moisture

The SOC observations were obtained from the LUCAS Soil Database provided through the European Soil Data Centre (ESDAC).

The study used 1,223 SOC observations from the Iberian Peninsula and divided them into:

- 70% training data
- 30% independent testing data

This corresponds to approximately:

- 859 training observations
- 364 testing observations

---

## Machine-Learning Models

### Random Forest

Random Forest is implemented using the `ranger` method in the `caret` framework.

The main tuning parameters include:

- `mtry`
- `splitrule`
- `min.node.size`

---

### XGBoost

Extreme Gradient Boosting is implemented using the `xgbTree` method in `caret`.

The following parameters are tuned:

- `nrounds`
- `max_depth`
- `eta`
- `gamma`
- `colsample_bytree`
- `min_child_weight`
- `subsample`

A reproducible random search is used to explore the predefined hyperparameter ranges.

---

### Support Vector Regression

Support Vector Regression is implemented using the radial-basis-function kernel.

The following parameters are tuned:

- `C`
- `sigma`

Predictors are centered and scaled before model fitting.

---

### Decision Tree

The Decision Tree model is implemented using the `rpart` algorithm.

The complexity parameter (`cp`) is tuned using cross-validation.

---

### Cubist

Cubist regression is used as a rule-based machine-learning model.

The following parameters are tuned:

- `committees`
- `neighbors`

---

## Model Validation

Model hyperparameters are optimized using repeated 10-fold cross-validation with five repetitions.

The independent test dataset is not used for hyperparameter optimization.

Three evaluation metrics are calculated:

### R²

Coefficient of determination.

Higher values indicate stronger agreement between observed and predicted SOC values.

### RMSE

Root Mean Square Error.

Lower values indicate better predictive performance.

### MAE

Mean Absolute Error.

Lower values indicate better predictive performance.

---

## Heterogeneous Ensemble

The five base models are combined using weighted averaging:

SOC_ensemble =

W_RF × P_RF +
W_XGB × P_XGB +
W_SVM × P_SVM +
W_DT × P_DT +
W_Cubist × P_Cubist

where:

- `W` represents the weight assigned to a model.
- `P` represents the corresponding model prediction.

The weights are constrained to sum to one:

W_RF + W_XGB + W_SVM + W_DT + W_Cubist = 1

### Weight Optimization

To avoid using the independent test dataset for weight optimization, ensemble weights are estimated using out-of-fold predictions generated from the training data.

A random search of 1,000 normalized weight combinations is performed.

The primary optimization criterion is R², followed by MAE and RMSE.

The independent test dataset is then used only once for final ensemble evaluation.

---

## Climate Change Scenario

Future SOC prediction is performed using projected climatic conditions under the SSP585 scenario.

The climate projections are based on the UKESM1-0-LL Earth System Model.

The future projection period considered in the study is:

**2021–2040**

Projected temperature and precipitation variables replace their historical counterparts during scenario prediction, while the remaining environmental predictors are kept unchanged.

---

## How to Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/HassanNiaB/SOC-Modeling-Iberian-Peninsula.git
   cd SOC-Modeling-Iberian-Peninsula
   2. Open RStudio and set working directory to the project root.
3. Run the scripts in order:
   ```r
   source("scripts/00_config.R")
   source("scripts/01_data_prep.R")
   source("scripts/02_train_models.R")
   source("scripts/03_ensemble.R")
   source("scripts/04_scenario_prediction.R")
   source("scripts/05_evaluation.R")
   ```
4. All outputs will be saved in the outputs/ directory.

---

Dependencies

The following R packages are required:

```r
install.packages(c(
  "caret",
  "xgboost",
  "randomForest",
  "e1071",
  "Cubist",
  "ranger",
  "rpart",
  "here"
))
```

---

Repository Structure

```text
SOC-Modeling-Iberian-Peninsula/
│
├── README.md
├── LICENSE
├── .gitignore
├── SOC_Ensemble_Modeling.Rproj
│
├── data/
│   └── raw/
│       ├── README.md
│       └── Scenario.csv
│
├── scripts/
│   ├── 00_config.R
│   ├── 01_data_prep.R
│   ├── 02_train_models.R
│   ├── 03_ensemble.R
│   ├── 04_scenario_prediction.R
│   └── 05_evaluation.R
│
└── outputs/
    ├── models/
    ├── predictions/
    └── figures/

Citation

If you use this code, please cite:

Hassan Nia Badrabad, H., Mirbagheri, B., & Shakiba, A. (2024). Modeling Soil Organic Carbon under Climate Change Scenario Using a Heterogeneous Ensemble Machine Learning Approach: A Case Study in Portugal and Spain.
