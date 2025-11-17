# # // Shared Private Link Resources - private link to storage account
# resource "azurerm_search_shared_private_link_service" "shared_private_link0" {

#   name                = "search-shared-private-link-0"
#   search_service_id   = module.aisearch.resource.id 
#   subresource_name    = local.base_shared_private_links[0].groupId
#   target_resource_id  = local.base_shared_private_links[0].privateLinkResourceId
#   request_message     = local.base_shared_private_links[0].requestMessage

#   depends_on = [
#     module.aiservices,
#     module.avm_res_storage_storageaccount,
#     module.aisearch,
#     null_resource.pause_before_next,
#    ]
# }

# # // Shared Private Link Resources - private link to cognitiveservices_account - ai services
# resource "azurerm_search_shared_private_link_service" "shared_private_link1" {

#   name                = "search-shared-private-link-1"
#   search_service_id   = module.aisearch.resource.id 
#   subresource_name    = local.base_shared_private_links[1].groupId
#   target_resource_id  = local.base_shared_private_links[1].privateLinkResourceId
#   request_message     = local.base_shared_private_links[1].requestMessage

#   depends_on = [
#     module.aiservices,
#     # module.avm_res_storage_storageaccount,
#     module.aisearch,
#     azurerm_search_shared_private_link_service.shared_private_link0,
#     null_resource.pause_before_next,
#    ]
# }


# resource "null_resource" "pause_before_next" {
#   provisioner "local-exec" {
#     command = "sleep 5"
#     interpreter = ["/bin/sh", "-c"]
#   }
# }
