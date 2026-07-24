# PagoDirecto Infra - Terraform (dev)

Infraestructura Azure para un clúster AKS con ArgoCD, entorno `dev`, proyecto PagoDirecto.

## Estructura

```
terraform/
  environments/dev/   entorno dev (unico entorno por ahora)
  modules/
    resource_group/
    network/
    aks/
    argocd/
```

## Nomenclatura

Patron: `<tipo>-<proyecto>-<entorno>-<region>-<instancia>`

| Recurso | Nombre |
|---|---|
| Resource Group | rg-pagodirecto-dev-eus2-001 |
| Virtual Network | vnet-pgd-dev-eus2-001 |
| Subnet AKS | snet-aks-pgd-dev-eus2-001 |
| AKS Cluster | aks-pgd-dev-eus2-001 |
| Log Analytics | log-pgd-dev-eus2-001 |
| Node pool sistema | default |
| Node pool usuario | user2 |
| Namespace ArgoCD | argocd |
| Namespace despliegues propios | user-2 |

Tags: `project=pagodirecto`, `environment=dev`, `managed-by=terraform`.

## Versiones fijas

- Terraform: 1.13.5
- azurerm: 4.81.0
- kubernetes: 3.2.1
- helm: 3.2.0
- Kubernetes AKS: 1.34
- Chart argo-cd: 10.2.1 (repo https://argoproj.github.io/argo-helm)

## Autenticacion a Azure

shell - entidad de servicio con permisos de Contributor en la suscripcion:

```bash
az account set --subscription "1d5c1ebe-7f10-4935-b92c-1c61527b475c"
```
```bash
az ad sp create-for-rbac --name "terraform-pagodirecto" --role Contributor --scopes /subscriptions/1d5c1ebe-7f10-4935-b92c-1c61527b475c
```


```
export ARM_CLIENT_ID="<APP_ID>"
export ARM_CLIENT_SECRET="<APP_SECRET>"
export ARM_TENANT_ID="<TENANT_ID>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
```

Rotar las credenciales antes de usarlo en cualquier entorno real:

```
az ad sp credential reset --id <APP_ID>
```

## Aplicar

El estado de Terraform se guarda localmente (`environments/dev/terraform.tfstate`), no hay backend remoto.

```
cd environments/dev
terraform init
terraform plan
terraform apply
```

## ArgoCD

El servicio `argocd-server` se expone como `LoadBalancer` publico. Obtener la IP:

```
kubectl get svc -n argocd argocd-server
```

Password inicial del usuario `admin`:

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

Cambiar la contrasena en el primer login: al quedar expuesto publicamente, cualquiera puede llegar a la pantalla de login.

## Node pools

- `default`: pods de sistema, ArgoCD y namespace `default`. Autoscaling 1-3 nodos.

Opcion en caso de tener un segundo nodo que es lo recomendable para entornos productivos.
Para desplegar en el pool `user2`, agregar en el manifiesto:

```
nodeSelector:
  workload: user-2
tolerations:
  - key: dedicated
    operator: Equal
    value: user-2
    effect: NoSchedule
```

`max_pods` esta fijado en 250 por nodo (Azure CNI Overlay) en ambos node pools.
