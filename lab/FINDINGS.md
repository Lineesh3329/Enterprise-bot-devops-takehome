# Findings — Part 4 Debug Lab

## Defect 1 — Migration Job Restart Policy

**Symptom:** During `./scenario.sh up`, Helm reported an invalid restart policy for the migration Job.

**Cause:** The Job used `restartPolicy: Always`, which is invalid for a Kubernetes Job.

**Fix:** Changed `restartPolicy` to `Never` so the migration container can complete successfully.

**How I found it:** Ran `./scenario.sh up`, inspected the Helm error, corrected `broken-chart/templates/migrate-job.yaml`, and confirmed that the migration Job completed.

---

## Defect 2 — Non-Root Container Configuration

**Symptom:** The supplied application image failed to start correctly when only `runAsNonRoot: true` was configured.

**Cause:** Kubernetes could not reliably verify the image's named non-root user without an explicit numeric user ID.

**Fix:** Added `runAsUser: 65532` and `runAsGroup: 65532`, retaining `runAsNonRoot: true`.

**How I found it:** Inspected pod startup errors and the image's user metadata, then configured numeric user and group IDs.

---

## Defect 3 — Reporter ServiceAccount Binding

**Symptom:** The verification check initially reported that the reporter ServiceAccount could not list pods.

**Cause:** The RoleBinding subject did not reference the intended `reporter` ServiceAccount.

**Fix:** Updated the RoleBinding to bind the `reporter-read` Role to ServiceAccount `reporter` in namespace `debug-lab`.

**How I found it:** Ran the following command and inspected the RoleBinding:

`kubectl auth can-i list pods --as=system:serviceaccount:debug-lab:reporter -n debug-lab`

The permission check subsequently returned `yes`.

---

## Defect 4 — Metrics CPU Resource Configuration

**Symptom:** The metrics workload had high CPU request and limit values in its chart configuration.

**Cause:** The original CPU request was `2` and the CPU limit was `4`.

**Fix:** Reduced the CPU request to `100m` and the CPU limit to `500m`, leaving the existing memory settings unchanged.

**How I found it:** Inspected the chart's resource configuration, adjusted the CPU values, and verified that the metrics deployment became ready.

---

## Defect 5 — Worker Cache Directory

**Symptom:** The worker logged that it could not initialise its cache because creating `/var/cache/app` failed on the read-only filesystem.

**Cause:** The worker needed a writable cache directory, but the deployment did not mount writable storage at that path.

**Fix:** Added an `emptyDir` volume mounted at `/var/cache/app`, retaining the read-only root filesystem.

**How I found it:** Inspected the worker logs, identified the required cache directory, added the volume mount, and confirmed that the worker became ready.

---

## Defect 6 — Application Ports and Reporter Health

**Symptom:** The reporter continued returning HTTP 503 with the log message `parse pod list: unexpected end of JSON input`. The latest verification also reported failures for the backend and gateway in-cluster probes.

**Cause:** The reporter's pod-list parsing failure remains unexplained. Its ServiceAccount can list pods, and a separate test pod successfully retrieved the Kubernetes API pod list. These checks do not establish why the reporter's own request fails.

**Fix:** Configured the affected application workloads to use port `8080`. The reporter issue remains unresolved.

**How I found it:** Inspected application logs, pod readiness, Service endpoints, Role and RoleBinding configuration, DNS resolution, and a separate in-cluster Kubernetes API request.

---

## Remaining Work and Limitations

The latest recorded execution of `./scenario.sh verify` reported **7 passing checks and 4 failing checks**.

The migration Job completed, and the backend, gateway, worker, and metrics deployments were Ready. The reporter remained unready, while the backend, gateway, and reporter in-cluster probe checks failed during that verification run.

Earlier direct requests to the backend and gateway returned HTTP 200, so their probe failures require a final recheck. The reporter's JSON parsing failure remains unresolved.

The original `scenario.sh` and `cluster-state/` files were not intentionally modified. Part 4 is not fully verified. Further investigation would compare the reporter's Kubernetes API request and response handling with the successful request from the test pod.
