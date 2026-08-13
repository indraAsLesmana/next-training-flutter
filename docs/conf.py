# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'Aplikasi Pengumpulan Tugas Training'
copyright = '2026, Indra Agus Lesmana | https://indra-blog.pages.dev/ | indra953@gmail.com'
author = 'Indra Agus Lesmana'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

# Enable MyST parser to read Markdown files + sphinx-design for tabs/cards
extensions = [
    'myst_parser',
    'sphinx_design',
    'sphinxcontrib.mermaid',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'rundown']

# -- Branch-aware visibility ------------------------------------------------
# LIVE ReadTheDocs (branch `main`) hanya menampilkan halaman Setup untuk
# peserta training. Semua materi sesi (session-1..4, planning) disembunyikan.
# Branch `build-project` (dan branch lain / build lokal) menampilkan SEMUA.
import subprocess
try:
    _branch = subprocess.run(
        ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
        capture_output=True, text=True, timeout=5,
    ).stdout.strip()
except Exception:
    _branch = ''
if _branch == 'main':
    exclude_patterns += ['session-*.md', 'planning.md']
    # Sesi sengaja disembunyikan di versi live — toctree di index.md tetap
    # mencantumkannya (agar build-project tidak butuh file terpisah).
    # Warning "toctree contains reference to excluded/nonexisting document"
    # adalah konsekuensi yang diharapkan, jadi di-suppress di branch main.
    suppress_warnings = ['toc']

# MyST configurations
myst_enable_extensions = [
    "colon_fence",
    "substitution",
]

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
# html_static_path = ['_static']
