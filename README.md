# FortiGate Terraform for Azure

There are multiple SKUs for FortiGate in Azure, make sure to select the correct one for your license type and desired version

As of 2026-07-01, the latest available SKUs are:

## 7.0

- 7.0.19
  - BYOL/FLEX
    - fortinet_fg-vm_byol_70 - Gen1 Intel/AMD
  - PAYG
    - fortinet_fg-vm_payg_70 - Gen1 Intel/AMD

## 7.2

- 7.2.13
  - BYOL/FLEX
    - fortinet_fg-vm_byol_72 - Gen1 Intel/AMD
    - fortinet_fg-vm_byol_72_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_72 - Gen1 Intel/AMD
    - fortinet_fg-vm_payg_72_arm64 - Gen2 Arm64

## 7.4

- 7.4.11
  - BYOL/FLEX
    - fortinet_fg-vm_byol_74 - Gen1 Intel/AMD
    - fortinet_fg-vm_byol_74_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_byol_74_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_74 - Gen1 Intel/AMD
    - fortinet_fg-vm_payg_74_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_payg_74_arm64 - Gen2 Arm64

- 7.4.12
  - BYOL/FLEX
    - fortinet_fg-vm_byol_74_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_byol_74_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_74_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_payg_74_arm64 - Gen2 Arm64

## 7.6

- 7.6.6
  - BYOL/FLEX
    - fortinet_fg-vm_byol_76 - Gen1 Intel/AMD
    - fortinet_fg-vm_byol_76_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_byol_76_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_76 - Gen1 Intel/AMD
    - fortinet_fg-vm_payg_76_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_payg_76_arm64 - Gen2 Arm64

- 7.6.7
  - BYOL/FLEX
    - fortinet_fg-vm_byol_76_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_byol_76_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_76_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_payg_76_arm64 - Gen2 Arm64

## 8.0

- 8.0.0
  - BYOL/FLEX
    - fortinet_fg-vm_byol_80 - Gen1 Intel/AMD
    - fortinet_fg-vm_byol_80_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_byol_80_arm64 - Gen2 Arm64
  - PAYG
    - fortinet_fg-vm_payg_80 - Gen1 Intel/AMD
    - fortinet_fg-vm_payg_80_g2 - Gen2 Intel/AMD
    - fortinet_fg-vm_payg_80_arm64 - Gen2 Arm64

## Azure Marketplace Terms

The Azure Marketplace Terms for the FortiGate-VM PAYG or BYOL/FLEX image in the Azure Marketplace need to be accepted once before usage. This is done automatically during deployment via the Azure Portal. When using Terraform the Azure CLI commands below can be used to accept the agreement or the Terraform resource be run before the first deployment in a subscription.

- BYOL/FLEX
  - az vm image terms accept --publisher fortinet --offer fortinet_fortigate-vm --plan fortinet_fg-vm-byol_80
- PAYG
  - az vm image terms accept --publisher fortinet --offer fortinet_fortigate-vm --plan fortinet_fg-vm_payg_80

- Terraform resource

```terraform
  resource "azurerm_marketplace_agreement" "marketplace_agreement_fortinet" {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm"
  plan      = "fortinet_fg-vm_payg_80"
}
```
