import { useEffect } from "react";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "./ui/dialog";
import { Badge } from "./ui/badge";
import { Command } from "lucide-react";
import { useState } from "react";

interface Shortcut {
  key: string;
  description: string;
  category: string;
}

const shortcuts: Shortcut[] = [
  { key: "I", description: "Create new invoice", category: "Actions" },
  { key: "C", description: "Add new client", category: "Actions" },
  { key: "P", description: "Record payment", category: "Actions" },
  { key: "/", description: "Focus search", category: "Navigation" },
  { key: "D", description: "Go to Dashboard", category: "Navigation" },
  { key: "N", description: "Toggle notifications", category: "Interface" },
  { key: "T", description: "Toggle dark mode", category: "Interface" },
  { key: "?", description: "Show keyboard shortcuts", category: "Help" },
  { key: "Esc", description: "Close dialogs/modals", category: "Navigation" },
];

interface KeyboardShortcutsProps {
  onCreateInvoice?: () => void;
  onAddClient?: () => void;
  onRecordPayment?: () => void;
  onNavigate?: (section: string) => void;
  onToggleTheme?: () => void;
  onFocusSearch?: () => void;
}

export function useKeyboardShortcuts({
  onCreateInvoice,
  onAddClient,
  onRecordPayment,
  onNavigate,
  onToggleTheme,
  onFocusSearch,
}: KeyboardShortcutsProps) {
  const [showHelp, setShowHelp] = useState(false);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // Ignore if user is typing in an input, textarea, or contenteditable element
      const target = e.target as HTMLElement;
      if (
        target.tagName === "INPUT" ||
        target.tagName === "TEXTAREA" ||
        target.contentEditable === "true"
      ) {
        // Allow Escape to work even in inputs
        if (e.key === "Escape") {
          target.blur();
        }
        return;
      }

      // Check for modifier keys (Ctrl/Cmd)
      const isMod = e.ctrlKey || e.metaKey;

      // Show help dialog
      if (e.key === "?" && e.shiftKey) {
        e.preventDefault();
        setShowHelp(true);
        return;
      }

      // All other shortcuts should not have modifiers
      if (isMod || e.altKey || e.shiftKey) return;

      switch (e.key.toLowerCase()) {
        case "i":
          e.preventDefault();
          onCreateInvoice?.();
          break;
        case "c":
          e.preventDefault();
          onAddClient?.();
          break;
        case "p":
          e.preventDefault();
          onRecordPayment?.();
          break;
        case "d":
          e.preventDefault();
          onNavigate?.("dashboard");
          break;
        case "t":
          e.preventDefault();
          onToggleTheme?.();
          break;
        case "/":
          e.preventDefault();
          onFocusSearch?.();
          break;
        case "n":
          e.preventDefault();
          // This will be handled by the notification bell component
          document.querySelector('[data-notification-trigger]')?.dispatchEvent(new Event('click'));
          break;
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [onCreateInvoice, onAddClient, onRecordPayment, onNavigate, onToggleTheme, onFocusSearch]);

  return { showHelp, setShowHelp };
}

interface KeyboardShortcutsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function KeyboardShortcutsDialog({ open, onOpenChange }: KeyboardShortcutsDialogProps) {
  const categories = Array.from(new Set(shortcuts.map(s => s.category)));

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Command className="h-5 w-5" />
            Keyboard Shortcuts
          </DialogTitle>
          <DialogDescription>
            Use these keyboard shortcuts to navigate faster
          </DialogDescription>
        </DialogHeader>
        
        <div className="space-y-6">
          {categories.map((category) => (
            <div key={category}>
              <h4 className="mb-3 text-sm font-semibold text-muted-foreground">{category}</h4>
              <div className="space-y-2">
                {shortcuts
                  .filter((s) => s.category === category)
                  .map((shortcut) => (
                    <div
                      key={shortcut.key}
                      className="flex items-center justify-between py-2 px-3 rounded-lg hover:bg-muted/50 transition-colors"
                    >
                      <span className="text-sm">{shortcut.description}</span>
                      <Badge variant="outline" className="font-mono">
                        {shortcut.key}
                      </Badge>
                    </div>
                  ))}
              </div>
            </div>
          ))}
        </div>

        <div className="pt-4 border-t border-border">
          <p className="text-xs text-muted-foreground text-center">
            Press <Badge variant="outline" className="font-mono mx-1">?</Badge> anytime to see this help
          </p>
        </div>
      </DialogContent>
    </Dialog>
  );
}
