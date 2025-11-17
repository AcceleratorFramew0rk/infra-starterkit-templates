locals {
  vm_indices = toset([for i in range(var.vm_count) : tostring(i)]) # Convert numbers to strings
}