"""
Makes `src/` importable as a package so notebooks can do:
    from src.features.complexity import compute_complexity_score
instead of relative imports / sys.path hacks.

Install in editable mode after creating your venv:
    pip install -e .
"""

from setuptools import find_packages, setup

setup(
    name="battery_passport_capstone",
    version="0.1.0",
    description="Data Analytics capstone — EU Battery Passport analysis",
    author="[Your Name]",
    packages=find_packages(),
    python_requires=">=3.10",
)
