# pbs-client

Installs the Proxmox Backup Server (PBS) apt repository and
`proxmox-backup-client`, and configures a backup script (optionally on a
cron schedule) that backs up named folders to a PBS datastore.

## Availability

Debian and Ubuntu only (this is the Proxmox `proxmox-backup-client`
package, distributed via Proxmox's Debian apt repos).

## Usage

```yaml
include:
  - pbs-client
```

Set `pbs-client:installed: false` (the default) to ensure the package,
repo, script, and cron job are all removed instead.

## Configuration

All configuration lives under the `pbs-client` pillar key. See
`pillar.example` for a full example.

When using the `salt_pass` formula, configure master-side decryption for this
compiled Pillar key (not for the similarly named path in the password store):

```yaml
salt_pass:
  decrypt_pillar_paths:
    - 'pbs-client'

pbs-client:
  password: 'pass:applications/pbs-client/password'
```

| Key            | Description                                                                 |
|------------------|--------------------------------------------------------------------------------|
| `installed`       | Whether the client should be installed (`true`) or removed (`false`)            |
| `repo`             | apt suite for the Proxmox repo (per-release override in `osfingermap.yaml`)      |
| `repository`        | PBS repository spec, `user@realm!token@host:datastore`                            |
| `password`           | PBS password/API token secret -- use an encrypted pillar in production             |
| `fingerprint`         | Optional TLS fingerprint to pin, if not using a trusted CA cert                     |
| `backup`               | List of `{name, path, exclude}` folders to back up                                   |
| `schedule`              | Optional cron expression; if unset, the script is installed but not scheduled        |
| `prune`                  | Optional retention flags passed to `proxmox-backup-client prune` after each backup    |

## Notes / audit findings

* **Security fix:** the PBS password used to be templated directly into
  `/usr/local/bin/backup-to-pbs` at mode `0755` -- readable by any local
  user. It now lives in `/etc/pbs-client/pbs-client.env` at mode `0600`
  (root-only), sourced by the script. Salt state output also suppresses diffs
  for this credential-bearing file.
* **Missing feature added:** nothing previously ran the backup script.
  `schedule.sls` now drops an `/etc/cron.d` entry when
  `pbs-client:schedule` is set.
* **Missing feature added:** optional `prune` retention support, and
  optional `fingerprint` pinning for hosts without a trusted TLS cert for
  the PBS server.
* **Bug fix:** `install.sls` previously installed the package without
  requiring `pbs-client.repo`, so applying `pbs-client.install` on its own
  (without also including `.repo` first) could fail on a fresh host.
  It now explicitly includes and requires the repo state.
* `repository`, `password`, and `backup` were referenced by the original
  template but were never documented in a `defaults.yaml` or pillar
  example -- both now exist.

## Relationship to upstream

**This formula was written from scratch for one specific deployment. It is
not a fork of anything, and there is no upstream to fall back to.**

There is no formula of this name in the
[saltstack-formulas](https://github.com/saltstack-formulas) project. What it borrows from that project is
convention, not code: the `map.jinja` + `defaults.yaml` pattern, pillar as
the single override surface, and the general layout. Anything that did come
from elsewhere is noted in the file headers.

Its states, pillar keys, and defaults are shaped around the deployment it
was built for. Read `pillar.example` before pointing it at anything you
care about — it has had far less exposure than a widely-used formula, so
expect rough edges on platforms other than the ones it was written against.

### Credit

The structure and conventions come from the
[saltstack-formulas](https://github.com/saltstack-formulas) project; credit for that groundwork belongs to
its authors and contributors.

## License

Dedicated to the public domain under [CC0 1.0 Universal](LICENSE).
