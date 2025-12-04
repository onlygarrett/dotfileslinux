. PHONY: help install uninstall restow update backup list

DOTFILES_DIR := $(HOME)/dotfiles
BACKUP_DIR := $(HOME)/dotfiles_backup_$(shell date +%Y%m%d_%H%M%S)

help:
	@echo "Dotfiles Management with GNU Stow"
	@echo ""
	@echo "Available targets:"
	@echo "  make install    - Stow all packages"
	@echo "  make uninstall  - Unstow all packages"
	@echo "  make restow     - Restow all packages (useful after updates)"
	@echo "  make update     - Pull latest changes and restow"
	@echo "  make backup     - Create backup of current dotfiles"
	@echo "  make list       - List all packages"
	@echo "  make help       - Show this help message"

install:
	@echo "Stowing all packages..."
	@cd $(DOTFILES_DIR) && for dir in */; do \
		pkg=$${dir%/}; \
		echo "Stowing $$pkg..."; \
		stow -v $$pkg; \
	done
	@echo "Done!"

uninstall:
	@echo "Unstowing all packages..."
	@cd $(DOTFILES_DIR) && for dir in */; do \
		pkg=$${dir%/}; \
		echo "Unstowing $$pkg..."; \
		stow -v -D $$pkg; \
	done
	@echo "Done!"

restow:
	@echo "Restowing all packages..."
	@cd $(DOTFILES_DIR) && for dir in */; do \
		pkg=$${dir%/}; \
		echo "Restowing $$pkg..."; \
		stow -v -R $$pkg; \
	done
	@echo "Done!"

update:
	@echo "Pulling latest changes..."
	@cd $(DOTFILES_DIR) && git pull
	@echo "Restowing packages..."
	@$(MAKE) restow

backup:
	@echo "Creating backup at $(BACKUP_DIR)..."
	@mkdir -p $(BACKUP_DIR)
	@cp -r $(DOTFILES_DIR)/* $(BACKUP_DIR)/
	@echo "Backup created at $(BACKUP_DIR)"

list:
	@echo "Available packages:"
	@cd $(DOTFILES_DIR) && for dir in */; do \
		echo "  - $${dir%/}"; \
	done

