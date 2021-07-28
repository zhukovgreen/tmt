import contextlib
import os
from pathlib import Path
from typing import ContextManager

from click.testing import CliRunner

import tmt.cli

runner = CliRunner()


@contextlib.contextmanager
def change_cwd(path: Path) -> ContextManager[None]:
    origin_dir = str(Path(".").absolute())
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(origin_dir)


def test_environment_file_normal_case():
    """Test if variables can be send via environment and environment-file params."""

    with change_cwd(Path(".") / "data"):

        # check if all tmt tests defined in ./data passed
        res = runner.invoke(
            tmt.cli.main,
            ["run", "-vvvddd"],
            catch_exceptions=False,
            )
        assert res.exit_code == 0
        assert "total: 1 test passed" in res.output

        # check if --environment is properly handled (override STR var)
        res = runner.invoke(
            tmt.cli.main,
            ["run", "--environment", "STR=bad_str", "-vvvddd"],
            catch_exceptions=False,
            )
        assert res.exit_code == 1
        assert "AssertionError: assert 'bad_str' == 'O'" in res.output

        # check if --environment-file is properly handled (override STR var)
        res = runner.invoke(
            tmt.cli.main,
            ["run", "--environment-file", ".env-via-cli", "-vvvddd"],
            catch_exceptions=False,
            )

        assert res.exit_code == 1
        assert "AssertionError: assert '2' == '1'" in res.output
