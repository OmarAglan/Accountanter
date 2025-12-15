import { Input } from "./ui/input";
import { Avatar, AvatarFallback, AvatarImage } from "./ui/avatar";
import { Search, Moon, Sun } from "lucide-react";
import { Button } from "./ui/button";
import { useTheme } from "./ThemeProvider";
import { NotificationBell } from "./NotificationCenter";
import { useRef } from "react";

interface HeaderProps {
  userName?: string;
  onSearchFocus?: () => void;
}

export function Header({ userName = "John", onSearchFocus }: HeaderProps) {
  const { theme, toggleTheme } = useTheme();
  const searchRef = useRef<HTMLInputElement>(null);

  const getGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  };

  // Expose focus method for keyboard shortcuts
  if (onSearchFocus && searchRef.current) {
    (window as any).__focusSearch = () => searchRef.current?.focus();
  }

  return (
    <header className="bg-card border-b border-border px-6 py-4 card-shadow">
      <div className="flex items-center justify-between">
        {/* Left side - Greeting */}
        <div>
          <h2 className="text-xl text-foreground">
            {getGreeting()}, {userName}
          </h2>
          <p className="text-sm text-muted-foreground">
            Here's what's happening with your business today
          </p>
        </div>

        {/* Right side - Search and Profile */}
        <div className="flex items-center gap-4">
          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              ref={searchRef}
              type="search"
              placeholder="Search clients, invoices... (Press /)"
              className="w-80 pl-10 bg-input-background"
            />
          </div>

          {/* Dark Mode Toggle */}
          <Button variant="ghost" size="sm" onClick={toggleTheme} title={`Switch to ${theme === 'light' ? 'dark' : 'light'} mode`}>
            {theme === "light" ? (
              <Moon className="h-5 w-5" />
            ) : (
              <Sun className="h-5 w-5" />
            )}
          </Button>

          {/* Notifications */}
          <NotificationBell />

          {/* User Avatar */}
          <div className="flex items-center gap-3">
            <Avatar className="h-10 w-10">
              <AvatarImage src="/placeholder-avatar.jpg" alt={userName} />
              <AvatarFallback className="bg-primary text-primary-foreground">
                {userName.charAt(0).toUpperCase()}
              </AvatarFallback>
            </Avatar>
            <div className="hidden sm:block">
              <p className="text-sm font-medium text-foreground">{userName} Doe</p>
              <p className="text-xs text-muted-foreground">Owner</p>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}