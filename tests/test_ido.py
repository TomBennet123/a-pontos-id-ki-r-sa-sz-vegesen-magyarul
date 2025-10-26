import datetime
import sys
from pathlib import Path

import pytest

sys.path.append(str(Path(__file__).resolve().parents[1]))

from ido import ora_perc_string


@pytest.mark.parametrize(
    "dt, expected",
    [
        (datetime.datetime(2023, 1, 1, 0, 0), "tizenkettő óra"),
        (datetime.datetime(2023, 1, 1, 13, 0), "egy óra"),
        (datetime.datetime(2023, 1, 1, 1, 5), "egy óra öt"),
        (datetime.datetime(2023, 1, 1, 1, 14), "egy perc múlva negyed kettő"),
        (datetime.datetime(2023, 1, 1, 1, 15), "negyed kettő"),
        (datetime.datetime(2023, 1, 1, 1, 20), "negyed kettő múlt öt perccel"),
        (datetime.datetime(2023, 1, 1, 1, 29), "egy perc múlva fél kettő"),
        (datetime.datetime(2023, 1, 1, 1, 30), "fél kettő"),
        (datetime.datetime(2023, 1, 1, 1, 35), "fél kettő múlt öt perccel"),
        (datetime.datetime(2023, 1, 1, 1, 44), "egy perc múlva háromnegyed kettő"),
        (datetime.datetime(2023, 1, 1, 1, 45), "háromnegyed kettő"),
        (datetime.datetime(2023, 1, 1, 1, 47), "háromnegyed kettő múlt két perccel"),
        (datetime.datetime(2023, 1, 1, 1, 58), "két perc múlva kettő"),
    ],
)
def test_ora_perc_string(dt, expected):
    assert ora_perc_string(dt) == expected
