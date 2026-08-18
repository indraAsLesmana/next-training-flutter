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
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store', 'rundown', 'apidog']

# -- Branch-aware visibility ------------------------------------------------
# LIVE ReadTheDocs (branch `main`) menampilkan Setup + Session 1 + Session 2 + Session 3 (homework).
# Session 4 (materi hari berikutnya) disembunyikan sampai tanggalnya tiba.
# Branch `build-project` (dan branch lain / build lokal) menampilkan SEMUA.
import os
import subprocess

# RTD exposes READTHEDOCS_GIT_IDENTIFIER = branch/ref yang di-checkout.
# Lokal: deteksi via `git rev-parse --abbrev-ref HEAD` (bisa detached → fallback '').
_branch = os.environ.get('READTHEDOCS_GIT_IDENTIFIER', '')
if not _branch:
    try:
        _branch = subprocess.run(
            ['git', 'rev-parse', '--abbrev-ref', 'HEAD'],
            capture_output=True, text=True, timeout=5,
        ).stdout.strip()
    except Exception:
        _branch = ''
if _branch == 'main':
    exclude_patterns += ['session-4.md']
    # Sesi berikutnya sengaja disembunyikan di versi live — toctree di index.md
    # tetap mencantumkannya (agar build-project tidak butuh file terpisah).
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
