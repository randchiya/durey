# GitHub Setup Instructions

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com)
2. Click the "+" icon in the top right
3. Select "New repository"
4. Fill in the details:
   - **Repository name**: durey
   - **Description**: Kurdish voting app with real-time results
   - **Visibility**: Private (or Public if you want)
   - **DO NOT** initialize with README (we already have one)
5. Click "Create repository"

## Step 2: Push to GitHub

After creating the repository, run these commands in your terminal:

```bash
cd durey

# Add the remote repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/durey.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Verify Upload

1. Go to your repository on GitHub
2. You should see all your files uploaded
3. The README.md will be displayed on the main page

## Important: Protect Sensitive Information

Before pushing, make sure:

- [ ] `.env` file is in `.gitignore` (already done)
- [ ] No Supabase credentials in code (use environment variables)
- [ ] No API keys committed
- [ ] `.gitignore` includes sensitive files

## Repository Structure on GitHub

Your repository will contain:
```
durey/
├── README.md                    # Project documentation
├── BUILD_IPA_GUIDE.md          # iOS build instructions
├── GITHUB_SETUP.md             # This file
├── lib/                        # Flutter source code
├── assets/                     # Images, fonts, etc.
├── android/                    # Android platform code
├── ios/                        # iOS platform code
├── supabase/                   # Database scripts
└── pubspec.yaml                # Dependencies
```

## Collaborating

To add collaborators:
1. Go to repository Settings
2. Click "Collaborators"
3. Add team members by username

## Cloning the Repository

Others can clone your repository:
```bash
git clone https://github.com/YOUR_USERNAME/durey.git
cd durey
flutter pub get
```

## Updating the Repository

After making changes:
```bash
git add .
git commit -m "Description of changes"
git push
```

## Common Git Commands

```bash
# Check status
git status

# View commit history
git log

# Create a new branch
git checkout -b feature-name

# Switch branches
git checkout main

# Pull latest changes
git pull

# View remote URL
git remote -v
```

## GitHub Actions (Optional)

You can set up automated builds using GitHub Actions. Create `.github/workflows/flutter.yml` for CI/CD.

## Issues and Project Management

Use GitHub's built-in tools:
- **Issues**: Track bugs and features
- **Projects**: Organize tasks
- **Wiki**: Additional documentation
- **Releases**: Version management

## Next Steps

1. Push code to GitHub ✓
2. Set up branch protection rules
3. Configure GitHub Actions for CI/CD
4. Add collaborators
5. Create issues for future features
6. Set up project board

## Support

For Git/GitHub help:
- [GitHub Docs](https://docs.github.com)
- [Git Documentation](https://git-scm.com/doc)
