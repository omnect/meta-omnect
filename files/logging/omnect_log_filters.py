import logging


class LayerParseWarningFilter(logging.Filter):
    """Drop bitbake parse warnings originating from third-party BSP layers we do
    not own, while keeping the identical warnings for our own recipes.

    Wired via BB_LOGCONFIG onto the BitBake.Parsing logger (see
    files/logging/bb-logging.json). BB_LOGCONFIG's dictConfig runs in the bitbake
    UI process, whose sys.path is only bitbake/lib, so this module must be reachable
    via that process's PYTHONPATH.
    """

    def __init__(self, name="", layers=None, needles=None):
        super().__init__(name)
        self.layers = layers or ["meta-phytec"]
        self.needles = needles or ["lack of whitespace around the assignment"]

    def filter(self, record):
        msg = record.getMessage()
        drop = (any(n in msg for n in self.needles)
                and any(l in msg for l in self.layers))
        return not drop
