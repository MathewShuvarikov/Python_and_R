import pandas as pd
import numpy as np
from scipy.stats import norm

def power_ratio_metric(df=None, X_col=None, Y_col=None, alpha=0.05, beta=0.2, mde=None, nobs=None):
    """
    Function for calculating MDE (minimal detectable effect) and/or Minimal number of observations
    for Delta Method T-test for Ratio Metrics
    General View of such metric: Metric = X/Y, Example RR = Recovery/Debt
    :param df: input dataframe
    :param X_col: nominator column (e.g. Recovery)
    :param Y_col: denominator column (e.g. Debt)
    :param alpha: probability of 1st type error (a.k.a. significance level)
    :param beta: probability of 2st type error (1-beta is Power of test)
    :param mde: minimal detectable effect
    :param nobs: minimal number of observations
    :return: mde or nobs
    """
    if df is None and X_col is None and Y_col is None:
        raise ValueError('df, Y_col, X_col cannot be None')

    if mde is None and nobs is None:
        raise ValueError('mde and nobs cannot simultaneously be None')

    mu_x = df[X_col].mean()
    mu_y = df[Y_col].mean()
    var_x = df[X_col].var()
    var_y = df[Y_col].var()
    cov_x_y = df[[X_col, Y_col]].cov().iloc[0, 1]

    f_return = None
    var_xy = 1/mu_y**2 * var_x - 2 * cov_x_y * mu_x/mu_y**3 + mu_x**2/mu_y**4 * var_y

    if nobs is None:
        n = (norm.ppf(1-alpha/2)+norm.ppf(1-beta))**2 * var_xy*2 / mde**2
        f_return = int(n)
    if mde is None:
        mde = np.sqrt((norm.ppf(1-alpha/2)+norm.ppf(1-beta))**2 * var_xy*2 / nobs)
        f_return = mde
    return f_return