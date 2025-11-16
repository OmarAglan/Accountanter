import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "./ui/table";
import { Badge } from "./ui/badge";
import { Button } from "./ui/button";
import { MoreHorizontal, ArrowUpDown, Edit, Trash2, Eye } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "./ui/dropdown-menu";

interface Column {
  key: string;
  label: string;
  type?: "text" | "currency" | "date" | "status" | "actions";
  align?: "left" | "center" | "right";
  sortable?: boolean;
}

interface DataTableProps {
  columns: Column[];
  data: Record<string, any>[];
  onRowAction?: (action: string, row: Record<string, any>) => void;
  onSort?: (column: string) => void;
}

export function DataTable({ columns, data, onRowAction, onSort }: DataTableProps) {
  const formatCell = (value: any, type?: string, columnKey?: string) => {
    switch (type) {
      case "currency":
        const numValue = typeof value === "number" ? value : 0;
        const isNegative = numValue < 0;
        const formattedValue = typeof value === "number" ? `$${Math.abs(value).toLocaleString()}` : value;
        
        // For outstanding balance, show different colors
        if (columnKey === "outstandingBalance") {
          return (
            <span className={`financial-amount font-medium ${
              isNegative ? "text-success" : "text-destructive"
            }`}>
              {isNegative ? `-${formattedValue}` : formattedValue}
            </span>
          );
        }
        
        return (
          <span className="financial-amount font-medium">
            {formattedValue}
          </span>
        );
      case "date":
        return new Date(value).toLocaleDateString('en-US', {
          year: 'numeric',
          month: 'short',
          day: 'numeric'
        });
      case "status":
        const getStatusStyle = (status: string) => {
          const statusLower = status?.toLowerCase();
          switch (statusLower) {
            case "paid":
            case "active":
              return "bg-success/10 text-success border-success/20";
            case "pending":
            case "due soon":
              return "bg-warning/10 text-warning border-warning/20";
            case "overdue":
            case "error":
              return "bg-destructive/10 text-destructive border-destructive/20";
            case "draft":
            case "inactive":
              return "bg-muted text-muted-foreground border-border";
            case "in stock":
              return "bg-success/10 text-success border-success/20";
            case "low stock":
              return "bg-warning/10 text-warning border-warning/20";
            case "out of stock":
              return "bg-destructive/10 text-destructive border-destructive/20";
            case "debtor":
              return "bg-primary/10 text-primary border-primary/20";
            case "creditor":
              return "bg-accent/10 text-accent border-accent/20";
            default:
              return "bg-muted text-muted-foreground border-border";
          }
        };
        return (
          <Badge
            variant="outline"
            className={`font-medium border ${getStatusStyle(value)}`}
          >
            {value}
          </Badge>
        );
      case "actions":
        return (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="ghost" className="h-8 w-8 p-0 hover:bg-accent/10">
                <MoreHorizontal className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-40">
              <DropdownMenuItem onClick={() => onRowAction?.("view", value)}>
                <Eye className="mr-2 h-4 w-4" />
                View
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => onRowAction?.("edit", value)}>
                <Edit className="mr-2 h-4 w-4" />
                Edit
              </DropdownMenuItem>
              <DropdownMenuItem 
                onClick={() => onRowAction?.("delete", value)}
                className="text-destructive focus:text-destructive"
              >
                <Trash2 className="mr-2 h-4 w-4" />
                Delete
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        );
      default:
        return value;
    }
  };

  return (
    <div className="border border-border rounded-lg overflow-hidden card-shadow">
      <Table>
        <TableHeader>
          <TableRow className="bg-muted/30 hover:bg-muted/30">
            {columns.map((column) => (
              <TableHead
                key={column.key}
                className={`font-semibold text-foreground ${
                  column.align === "right" ? "text-right" : ""
                } ${column.align === "center" ? "text-center" : ""} ${
                  column.sortable ? "cursor-pointer hover:text-primary" : ""
                }`}
                onClick={() => column.sortable && onSort?.(column.key)}
              >
                <div className={`flex items-center gap-2 ${
                  column.align === "right" ? "justify-end" : 
                  column.align === "center" ? "justify-center" : ""
                }`}>
                  {column.label}
                  {column.sortable && (
                    <ArrowUpDown className="h-3 w-3 text-muted-foreground" />
                  )}
                </div>
              </TableHead>
            ))}
          </TableRow>
        </TableHeader>
        <TableBody>
          {data.map((row, index) => (
            <TableRow 
              key={index} 
              className="table-row-hover transition-colors duration-150 border-border"
            >
              {columns.map((column) => (
                <TableCell
                  key={column.key}
                  className={`${column.align === "right" ? "text-right" : ""}
                    ${column.align === "center" ? "text-center" : ""} py-4`}
                >
                  {formatCell(
                    column.type === "actions" ? row : row[column.key],
                    column.type,
                    column.key
                  )}
                </TableCell>
              ))}
            </TableRow>
          ))}
          {data.length === 0 && (
            <TableRow>
              <TableCell 
                colSpan={columns.length} 
                className="text-center py-8 text-muted-foreground"
              >
                No data available
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
}