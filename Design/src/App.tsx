import { useState } from "react";
import { Login } from "./components/Login";
import { Header } from "./components/Header";
import { Dashboard } from "./components/Dashboard";
import { Clients } from "./components/Clients";
import { Invoices } from "./components/Invoices";
import { Inventory } from "./components/Inventory";
import { InvoiceEditor } from "./components/InvoiceEditor";
import { Settings } from "./components/Settings";
import { Reports } from "./components/Reports";
import { Expenses } from "./components/Expenses";
import { Help } from "./components/Help";
import { PaymentTracking } from "./components/PaymentTracking";
import { RecurringInvoices } from "./components/RecurringInvoices";
import { TaxManagement } from "./components/TaxManagement";
import { MultiCurrency } from "./components/MultiCurrency";
import { DocumentManagement } from "./components/DocumentManagement";
import { ThemeProvider } from "./components/ThemeProvider";
import { NotificationProvider } from "./components/NotificationCenter";
import { useKeyboardShortcuts, KeyboardShortcutsDialog } from "./components/KeyboardShortcuts";
import { Toaster } from "./components/ui/sonner";
import { Button } from "./components/ui/button";
import {
  LayoutDashboard,
  Users,
  FileText,
  Package,
  Settings as SettingsIcon,
  HelpCircle,
  Menu,
  X,
  LogOut,
  BarChart3,
  Receipt,
  CreditCard,
  Repeat,
  Calculator,
  Globe,
  FolderOpen,
} from "lucide-react";

function AppContent() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [activeSection, setActiveSection] = useState("dashboard");
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [showInvoiceEditor, setShowInvoiceEditor] = useState(false);
  const [editingInvoice, setEditingInvoice] = useState<string | null>(null);
  const [invoiceFilter, setInvoiceFilter] = useState<string | undefined>(undefined);

  const navigationItems = [
    {
      id: "dashboard",
      label: "Dashboard",
      icon: LayoutDashboard,
      component: Dashboard,
    },
    {
      id: "clients",
      label: "Clients",
      icon: Users,
      component: Clients,
    },
    {
      id: "invoices",
      label: "Invoices",
      icon: FileText,
      component: Invoices,
    },
    {
      id: "recurring",
      label: "Recurring",
      icon: Repeat,
      component: RecurringInvoices,
    },
    {
      id: "payments",
      label: "Payments",
      icon: CreditCard,
      component: PaymentTracking,
    },
    {
      id: "inventory",
      label: "Inventory",
      icon: Package,
      component: Inventory,
    },
    {
      id: "expenses",
      label: "Expenses",
      icon: Receipt,
      component: Expenses,
    },
    {
      id: "taxes",
      label: "Taxes",
      icon: Calculator,
      component: TaxManagement,
    },
    {
      id: "currency",
      label: "Currency",
      icon: Globe,
      component: MultiCurrency,
    },
    {
      id: "documents",
      label: "Documents",
      icon: FolderOpen,
      component: DocumentManagement,
    },
    {
      id: "reports",
      label: "Reports",
      icon: BarChart3,
      component: Reports,
    },
    {
      id: "settings",
      label: "Settings",
      icon: SettingsIcon,
      component: Settings,
    },
    {
      id: "help",
      label: "Help",
      icon: HelpCircle,
      component: Help,
    },
  ];

  const handleLogin = () => {
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setActiveSection("dashboard");
    setShowInvoiceEditor(false);
    setEditingInvoice(null);
  };

  const handleCreateInvoice = () => {
    setShowInvoiceEditor(true);
    setEditingInvoice(null);
  };

  const handleEditInvoice = (invoiceId: string) => {
    setShowInvoiceEditor(true);
    setEditingInvoice(invoiceId);
  };

  const handleBackFromInvoiceEditor = () => {
    setShowInvoiceEditor(false);
    setEditingInvoice(null);
    setActiveSection("invoices");
  };

  const handleSaveInvoice = (isDraft: boolean) => {
    console.log(`Invoice saved as ${isDraft ? 'draft' : 'sent'}`);
    setShowInvoiceEditor(false);
    setEditingInvoice(null);
    setActiveSection("invoices");
  };

  const handleNavigate = (section: string, filter?: string) => {
    setActiveSection(section);
    if (section === "invoices" && filter) {
      setInvoiceFilter(filter);
    } else {
      setInvoiceFilter(undefined);
    }
  };

  const handleFocusSearch = () => {
    if (typeof (window as any).__focusSearch === 'function') {
      (window as any).__focusSearch();
    }
  };

  const { showHelp, setShowHelp } = useKeyboardShortcuts({
    onCreateInvoice: () => !showInvoiceEditor && handleCreateInvoice(),
    onAddClient: () => console.log("Add client"),
    onRecordPayment: () => handleNavigate("payments"),
    onNavigate: handleNavigate,
    onToggleTheme: () => {
      // Theme toggle is handled by the header component
      document.querySelector('[title*="Switch to"]')?.dispatchEvent(new Event('click'));
    },
    onFocusSearch: handleFocusSearch,
  });

  const ActiveComponent = navigationItems.find(
    (item) => item.id === activeSection
  )?.component || Dashboard;

  // Show login screen if not authenticated
  if (!isAuthenticated) {
    return <Login onLogin={handleLogin} />;
  }

  // Show invoice editor if active
  if (showInvoiceEditor) {
    return (
      <div className="min-h-screen bg-background">
        <div className="p-6 max-w-7xl mx-auto">
          <InvoiceEditor
            isEditing={!!editingInvoice}
            invoiceNumber={editingInvoice || undefined}
            onBack={handleBackFromInvoiceEditor}
            onSave={handleSaveInvoice}
          />
        </div>
      </div>
    );
  }

  return (
    <>
      <div className="flex h-screen bg-background">
        {/* Sidebar */}
        <aside
          className={`${
            sidebarOpen ? "w-64" : "w-16"
          } bg-sidebar border-r border-sidebar-border transition-all duration-300 flex flex-col`}
        >
          {/* Sidebar Header */}
          <div className="p-4 border-b border-sidebar-border">
            <div className="flex items-center justify-between">
              {sidebarOpen && (
                <div className="flex items-center space-x-2">
                  <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                    <Package className="w-5 h-5 text-primary-foreground" />
                  </div>
                  <h1 className="font-semibold text-sidebar-foreground">
                    Accountanter
                  </h1>
                </div>
              )}
              <Button
                variant="ghost"
                size="sm"
                onClick={() => setSidebarOpen(!sidebarOpen)}
                className="text-sidebar-foreground hover:bg-sidebar-accent"
              >
                {sidebarOpen ? (
                  <X className="h-4 w-4" />
                ) : (
                  <Menu className="h-4 w-4" />
                )}
              </Button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 p-4 space-y-2">
            {navigationItems.map((item) => (
              <Button
                key={item.id}
                variant={activeSection === item.id ? "default" : "ghost"}
                className={`w-full justify-start ${
                  sidebarOpen ? "px-3" : "px-2"
                } ${
                  activeSection === item.id
                    ? "bg-sidebar-primary text-sidebar-primary-foreground"
                    : "text-sidebar-foreground hover:bg-sidebar-accent"
                }`}
                onClick={() => setActiveSection(item.id)}
              >
                <item.icon className={`h-5 w-5 ${sidebarOpen ? "mr-3" : ""}`} />
                {sidebarOpen && item.label}
              </Button>
            ))}
          </nav>

          {/* Sidebar Footer */}
          <div className="p-4 border-t border-sidebar-border space-y-2">
            <Button
              variant="ghost"
              onClick={handleLogout}
              className={`w-full justify-start ${
                sidebarOpen ? "px-3" : "px-2"
              } text-sidebar-foreground hover:bg-sidebar-accent`}
            >
              <LogOut className={`h-5 w-5 ${sidebarOpen ? "mr-3" : ""}`} />
              {sidebarOpen && "Logout"}
            </Button>
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-auto">
          <Header userName="John" onSearchFocus={handleFocusSearch} />
          <div className="p-6 max-w-7xl mx-auto">
            <ActiveComponent 
              onCreateInvoice={handleCreateInvoice}
              onEditInvoice={handleEditInvoice}
              onAddClient={() => console.log("Add client")}
              onNavigate={handleNavigate}
              filter={invoiceFilter}
            />
          </div>
        </main>
      </div>
      <KeyboardShortcutsDialog open={showHelp} onOpenChange={setShowHelp} />
      <Toaster />
    </>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <NotificationProvider>
        <AppContent />
      </NotificationProvider>
    </ThemeProvider>
  );
}