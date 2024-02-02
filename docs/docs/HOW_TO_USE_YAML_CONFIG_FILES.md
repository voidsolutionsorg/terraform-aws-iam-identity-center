# Guide: How to use yaml config files to set variables

## Warning

`.yaml` files take precedence over `.yml` files, and both take precedence over Terraform variables

## Create yaml config files

1. Create a folder named `conf` inside your module directory and relevant config files inside that folder. If you don't define some of the config files, Terraform variables will be used instead.

2. Create `permission_sets.yaml` or `permission_sets.yml`:

```yaml
# permission sets
```

3. Create `groups.yaml` or `groups.yml`:

```yaml
# groups
```

4. Create `attachments.yaml` or `attachments.yml`:

```yaml
# attachments
```

5. Create `users.yaml` or `users.yml`:

```yaml
# users
```
