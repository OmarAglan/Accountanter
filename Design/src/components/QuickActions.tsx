import { Button } from "./ui/button";
import { Plus, UserPlus, FileText, Package } from "lucide-react";

interface QuickActionsProps {
  onCreateInvoice?: () => void;
  onAddClient?: () => void;
  onAddInventory?: () => void;
}

export function QuickActions({ 
  onCreateInvoice, 
  onAddClient, 
  onAddInventory 
}: QuickActionsProps) {
  return (
    <div className="flex flex-wrap gap-4">
      <Button 
        onClick={onCreateInvoice}
        className="bg-accent hover:bg-accent/90 text-accent-foreground"
        size="lg"
      >
        <FileText className="mr-2 h-5 w-5" />
        Create New Invoice
      </Button>
      
      <Button 
        onClick={onAddClient}
        variant="outline"
        size="lg"
        className="border-primary text-primary hover:bg-primary hover:text-primary-foreground"
      >
        <UserPlus className="mr-2 h-5 w-5" />
        Add New Client
      </Button>

      <Button 
        onClick={onAddInventory}
        variant="outline"
        size="lg"
        className="border-accent text-accent hover:bg-accent hover:text-accent-foreground"
      >
        <Package className="mr-2 h-5 w-5" />
        Add Inventory Item
      </Button>
    </div>
  );
}