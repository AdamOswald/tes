from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score, roc_auc_score
from mtr_utils import config as cfg


class scoringFunctions:

    def f1bin(self, y_pred):
        return f1_score(y_true=self, y_pred=y_pred)

    def f1mac(self, y_pred):
        return f1_score(y_true=self, y_pred=y_pred, average='macro')

    def accuracy(self, y_pred):
        return accuracy_score(y_true=self, y_pred=y_pred)

    def precision(self, y_pred):
        return precision_score(y_true=self, y_pred=y_pred, zero_division=0)

    def recall(self, y_pred):
        return recall_score(y_true=self, y_pred=y_pred, zero_division=0)

    def rocauc(self, y_pred):
        return roc_auc_score(y_true=self, y_score=y_pred)


metrics = {
    'f1-bin': scoringFunctions.f1bin,
    'f1-mac': scoringFunctions.f1mac,
    'accura': scoringFunctions.accuracy,
    'precis': scoringFunctions.precision,
    'recall': scoringFunctions.recall,
    'rocauc': scoringFunctions.rocauc,
}

current_metrics = {k: v for k, v in metrics.items() if k in cfg.METRICS}


def get_scoring(estimator, x_test, y_test):

    y_pred = estimator.predict(x_test)

    return {
        metric: scoring_func(y_test, y_pred)
        for metric, scoring_func in current_metrics.items()
    }
