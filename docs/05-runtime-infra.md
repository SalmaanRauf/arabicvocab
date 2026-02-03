# Runtime, Deployments, and Infrastructure

## Environments

- Local development: `flutter run -d chrome`. Defined in: `quran_vocab/README.md`.
- Staging and production: Unknown. No environment configuration files were found. Verification steps: search for `.env`, `docker-compose`, or hosting docs.

## Infrastructure as Code

Unknown. No Terraform, CDK, Helm, or similar IaC configs were found in the repo. Verification steps: check for `infra/`, `terraform/`, `helm/`, or `k8s/` directories.

## Networking and Service Discovery

- Runtime networking is limited to audio file fetches from EveryAyah CDN. Defined in: `quran_vocab/lib/services/audio/audio_manager.dart`.
- Data access is local via bundled JSON assets. Defined in: `quran_vocab/lib/data/data_loader.dart`.

## Observability

Unknown. No logging or monitoring integrations are defined. Verification steps: search for logging SDKs or analytics packages in `pubspec.yaml`.

## Scaling Considerations

- Flutter web bundle is static and can be served by any static host. This is a standard Flutter web deployment assumption and is not defined in repo. Marked as Assumption.
- Memory usage depends on size of JSON assets loaded at startup. Defined in: `quran_vocab/lib/data/data_loader.dart`.

## Runtime Limits

- Audio playback depends on CDN availability and browser audio policies. Defined in: `quran_vocab/lib/services/audio/audio_manager.dart`.
