#!/usr/bin/env python3
"""
Generate README for public repository
"""
import os
import sys
from datetime import datetime

def generate_readme(pub_repo_name, source_repo, commit_sha, sync_time):
    """Generate README content for public repository"""
    
    # Check if there's an existing README to preserve
    readme_content = ""
    if os.path.exists("README.md"):
        with open("README.md", "r", encoding="utf-8") as f:
            content = f.read()
            # Remove any existing public repo info
            if "---\n\n## 📢 Public Repository Information" in content:
                readme_content = content.split("---\n\n## 📢 Public Repository Information")[0].rstrip()
            else:
                readme_content = content.rstrip()
    
    # If no README content, create basic one
    if not readme_content:
        readme_content = f"""# {pub_repo_name}

This is a **public version** of the main project.

## Description

This repository contains selected files from the main project that are suitable for public sharing."""
    
    # Append public repository information
    project_name = source_repo.split('/')[-1].replace('-Pub', '')
    public_info = f"""

---

## 📢 Public Repository Information

This is a **public version** of the **{project_name}** project.

This repository contains carefully selected files from the main project that are suitable for public sharing and collaboration.

### 🔄 Automatic Synchronization

The content of this repository is automatically synchronized using GitHub Actions.

- **Last synchronization:** {sync_time}
- **Source commit:** `{commit_sha[:7]}`
- **Synchronization rules:** Controlled by automated configuration

### 🤝 Contributing

If you find this project useful or have suggestions for improvement, feel free to:
- ⭐ Star this repository
- 🐛 Report issues or bugs
- 💡 Suggest new features
- 🔄 Submit pull requests

### 📞 Contact

For questions about this project or collaboration opportunities, please create an issue in this repository."""
    
    return readme_content + public_info

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: generate_readme.py <pub_repo_name> <source_repo> <commit_sha> <sync_time>")
        sys.exit(1)
    
    pub_repo_name = sys.argv[1]
    source_repo = sys.argv[2]
    commit_sha = sys.argv[3]
    sync_time = sys.argv[4]
    
    readme_content = generate_readme(pub_repo_name, source_repo, commit_sha, sync_time)
    
    with open("README.md", "w", encoding="utf-8") as f:
        f.write(readme_content)
    
    print("✅ README.md generated successfully")
