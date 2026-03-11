# Lock & Archer – Test PDS

A [Bluesky PDS](https://github.com/bluesky-social/pds) (Personal Data Server) set up for testing the [Lock and Archer](https://github.com/bluesky-social/nextjs-oauth-tutorial) OAuth/Statusphere app. Based on the [AT Protocol self-hosting guide](https://atproto.com/guides/self-hosting).

This image adds:

- **First-run account seeding**: On first start (with a fresh volume), creates 3 test accounts so you can sign in from the app without manual setup.
- **Railway-ready**: Uses `PORT` and a single Dockerfile so you can deploy from GitHub to Railway.

## Deploy to Railway

### 1. Create the project

1. Push this repo to GitHub (e.g. `your-username/lock-and-archer-pds`).
2. In [Railway](https://railway.app), click **New Project** → **Deploy from GitHub repo** and select this repo.
3. Railway will detect the Dockerfile and build the image.

### 2. Add a volume

PDS needs persistent storage for accounts and repo data.

1. Open your service → **Settings** (or **Variables**).
2. Click **Add Volume** (or **Attach Volume**).
3. Set mount path to **`/pds`**.

### 3. Generate a domain

1. Open the service → **Settings** → **Networking**.
2. Click **Generate Domain** (e.g. `lock-and-archer-pds.up.railway.app`).
3. Set the service port to **3000** if Railway doesn’t auto-detect it (or whatever port your Dockerfile exposes).

### 4. Set environment variables

In the service **Variables** tab, set:

| Variable | How to get it |
|----------|----------------|
| `PDS_HOSTNAME` | Your Railway domain **with `https://`**, e.g. `https://lock-and-archer-pds.up.railway.app` (no trailing slash). |
| `PDS_JWT_SECRET` | `openssl rand --hex 16` |
| `PDS_ADMIN_PASSWORD` | `openssl rand --hex 16` (save it; you need it for goat and for re-running seed). |
| `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX` | Run: `openssl ecparam -name secp256k1 -genkey -noout -outform DER \| tail -c +8 \| head -c 32 \| xxd -p -c 32` |

**Optional:** Copy `.env.example` to `.env` and fill values for local runs.

### 5. Deploy

After saving variables, Railway will redeploy. On **first deploy with an empty volume**, the entrypoint will:

1. Start the PDS briefly.
2. Create 3 test accounts (see below).
3. Restart the PDS and run it normally.

Subsequent restarts skip account creation (a marker file is written in `/pds`).

## Test accounts (after first run)

If seed ran successfully, you’ll have (password for all: **`testpass123`**):

- **alice.&lt;your-pds-hostname&gt;** (e.g. `alice.lock-and-archer-pds.up.railway.app`)
- **bob.&lt;your-pds-hostname&gt;**
- **carol.&lt;your-pds-hostname&gt;**

Use these handles in your Lock and Archer app (Statusphere) login. No email verification is required for local/testing use unless you configure SMTP.

## Using this PDS from the Lock and Archer app

1. Deploy this PDS on Railway and note `PDS_HOSTNAME` (e.g. `https://lock-and-archer-pds.up.railway.app`).
2. In the Lock and Archer app, sign in with a handle like `alice.lock-and-archer-pds.up.railway.app`.
3. The app will resolve the handle to this PDS and use it for OAuth and for writing `xyz.statusphere.status` records. A self-hosted PDS allows custom lexicons (or `validate: false`), which avoids the “Unable to fulfill XRPC request” error you may see with bsky.social.

## Recreating test accounts

If you remove the volume and redeploy, or delete the marker file in `/pds` (`.test_accounts_created`), the next start will run the seed again. To create more accounts manually, use [goat](https://github.com/bluesky-social/goat) against the running PDS (e.g. from a one-off container or a host that can reach the PDS):

```bash
goat pds admin account create \
  --admin-password YOUR_PDS_ADMIN_PASSWORD \
  --pds-host https://your-pds.up.railway.app \
  --handle dave.your-pds.up.railway.app \
  --email dave@example.com \
  --password testpass123
```

## Health check

- **URL:** `https://<PDS_HOSTNAME>/xrpc/_health`
- **Expected:** JSON like `{"version":"0.4.0"}` (version may vary).

## References

- [Self-hosting (AT Protocol)](https://atproto.com/guides/self-hosting)
- [PDS repository](https://github.com/bluesky-social/pds)
- [goat CLI](https://github.com/bluesky-social/goat)
