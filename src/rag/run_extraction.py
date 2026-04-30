"""
RAG extraction pipeline for Act 4 — manufacturer disclosure assessment.

For each (manufacturer, attribute) pair, queries the manufacturer's sustainability
report via a RAG layer and captures:
    - extracted answer
    - supporting source quote
    - page reference (if available)
    - raw model response

OUTPUTS ARE NOT SCORED HERE. Scoring happens after manual validation in
notebooks/09-act4-validation.ipynb.

Run from project root:
    python src/rag/run_extraction.py

Requires OPENAI_API_KEY in .env.
"""

from __future__ import annotations

import json
import os
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()

# ------------------------------------------------------------
# Configuration — finalize on Day 0 after smoke test
# ------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parents[2]
REPORTS_DIR = PROJECT_ROOT / "data" / "raw" / "manufacturer_reports"
OUTPUTS_DIR = PROJECT_ROOT / "data" / "raw" / "rag_extractions"

OPENAI_MODEL = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
TEMPERATURE = float(os.getenv("RAG_TEMPERATURE", "0.0"))

# Locked on Day 0 — see Trello card "Pick the 8 attributes for Act 4"
TARGET_ATTRIBUTES: list[str] = [
    # "Carbon footprint",
    # "Recycled content — cobalt",
    # ...etc; fill in on Day 0
]

# Locked on Day 0 — see Trello card "Manufacturer reports availability check"
MANUFACTURERS: list[str] = [
    # "CATL",
    # "BYD",
    # ...etc; fill in on Day 0
]

# Locked on Day 3 — see Trello card "Act 4 prep"
PROMPT_TEMPLATE = """\
You are extracting structured disclosure information from a battery manufacturer's
sustainability or ESG report.

Manufacturer: {manufacturer}
Attribute under question: {attribute}

Find any disclosure related to this attribute. Return a JSON object with these fields:
    - "disclosed": one of "yes", "partial", "no"
    - "summary": one-sentence summary of what is disclosed (or "none" if not disclosed)
    - "source_quote": exact quote from the report supporting the answer (or "")
    - "page_reference": page number if identifiable (or null)

If the attribute is not addressed in the report, return "disclosed": "no".
Do NOT hallucinate quotes. If you cannot find a supporting quote, return "".

Respond ONLY with the JSON object, no other text.
"""


def query_rag(manufacturer: str, attribute: str) -> dict:
    """
    Run a single RAG query.

    To implement on Day 6 once the smoke-test stack is chosen.
    Suggested implementation: OpenAI Assistants API with file_search tool,
    one assistant per manufacturer pre-loaded with their report.
    """
    raise NotImplementedError("Implement on Day 6 after smoke test stack is finalized")


def main() -> None:
    OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)

    if not TARGET_ATTRIBUTES or not MANUFACTURERS:
        raise RuntimeError(
            "Lock TARGET_ATTRIBUTES and MANUFACTURERS in this file before running. "
            "See Day 0 and Day 3 Trello cards."
        )

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = OUTPUTS_DIR / f"extractions_{timestamp}.jsonl"

    total = len(MANUFACTURERS) * len(TARGET_ATTRIBUTES)
    print(f"Running {total} extractions, output → {output_file}")

    with output_file.open("w") as f:
        for manufacturer in MANUFACTURERS:
            for attribute in TARGET_ATTRIBUTES:
                result = query_rag(manufacturer, attribute)
                record = {
                    "manufacturer": manufacturer,
                    "attribute": attribute,
                    "timestamp": datetime.now().isoformat(),
                    "model": OPENAI_MODEL,
                    "result": result,
                }
                f.write(json.dumps(record) + "\n")
                f.flush()

    print(f"Done. Validate every row before scoring.")


if __name__ == "__main__":
    main()
