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


def ratio_t_test(control_df=None, pilot_df=None, x_col=None, y_col=None, alternative='two-sided'):
    """
    Test for calculating statistical significance of ratio metrics (Delta Method)
    Arguments:
    control_df - input control group dataframe
    pilot_df - input pilot group dataframe
    x_col - nominator column (e.g. Recovery)
    y_col - denominator column (e.g. Debt)
    alternative - what type of hypothesis is tested? ['two-sided', 'larger', 'smaller']
    """
    import pandas as pd
    import numpy as np
    from scipy.stats import norm
    
    # Pilot
    mu_x_pilot = pilot_df[x_col].mean()
    mu_y_pilot = pilot_df[y_col].mean()
    var_x_pilot = pilot_df[x_col].var()
    var_y_pilot= pilot_df[y_col].var()
    cov_x_y_pilot = pilot_df[[x_col, y_col]].cov().iloc[0,1]

    var_xy_pilot = 1/mu_y_pilot**2 * var_x_pilot - 2 * cov_x_y_pilot * mu_x_pilot/mu_y_pilot**3 + mu_x_pilot**2/mu_y_pilot**4 * var_y_pilot
    pilot_metric = mu_x_pilot/mu_y_pilot
   
    # control
    mu_x_control = control_df[x_col].mean()
    mu_y_control = control_df[y_col].mean()
    var_x_control = control_df[x_col].var()
    var_y_control= control_df[y_col].var()
    cov_x_y_control = control_df[[x_col, y_col]].cov().iloc[0,1]

    var_xy_control = 1/mu_y_control**2 * var_x_control - 2 * cov_x_y_control * mu_x_control/mu_y_control**3 + mu_x_control**2/mu_y_control**4 * var_y_control

    control_metric = mu_x_control/mu_y_control

    print({ 'Mu(X/Y) pilot': round(pilot_metric, 3), 'Var(X/Y) pilot': round(var_xy_pilot, 3),

           'Mu(X/Y) control': round(control_metric, 3), 'Var(X/Y) control': round(var_xy_control, 3), })

    diff = pilot_metric-control_metric
    t_stat = (diff)/np.sqrt(var_xy_control+var_xy_pilot)

    if alternative == 'two-sided':
        p_val = (1-norm.cdf(abs(t_stat)))*2
    elif alternative == 'larger':
        p_val = 1-norm.cdf(t_stat)  
    else:
        p_val = norm.cdf(t_stat)

    # print('t_stat', round(t_stat, 3), 'p_val', round(p_val, 3))   
    return diff,t_stat, p_val