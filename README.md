# User Cluster Monitoring Logging & Alerting Stack for Kubermatic Kubernetes Platform

This repository contains Helm Charts of the Seed Cluster components for the [User Cluster Monitoring Logging & Alerting (MLA) stack][20] of the [Kubermatic Kubernetes Platform][10] (KKP).

## Documentation

Please follow the documentation at [docs.kubermatic.com](https://docs.kubermatic.com/) for more details:

- [Architecture][20]
- [Admin Guide][21]
- [User Guide][22]

Please use the version selector at the top of the site to ensure you are using the appropriate documentation for your version of Kubermatic.

## KKP Compatibility Matrix

Please use the version tag of this repo matching with your Kubermatic Kubernetes Platform version according to this table:

| MLA Version Tag | Compatible KKP Versions
|-----------------|-------------
| v0.1.0          |  v2.18.0

## Installing MLA Stack in a KKP Seed Cluster

Please follow the [Admin Guide][21].

## Troubleshooting

If you encounter issues [file an issue][1] or talk to us on the [#kubermatic channel][12] on the [Kubermatic Slack][15].

## Contributing

Thanks for taking the time to join our community and start contributing!

Feedback and discussion are available on [the mailing list][11].

### Before you start

* Please familiarize yourself with the [Code of Conduct][4] before contributing.
* See [CONTRIBUTING.md][2] for instructions on the developer certificate of origin that we require.
* Read how [we're using ZenHub][13] for project and roadmap planning

### Pull requests

* We welcome pull requests. Feel free to dig through the [issues][1] and jump in.

## Changelog

See [the list of releases][3] to find out about feature changes.

[1]: https://github.com/kubermatic/mla/issues
[2]: https://github.com/kubermatic/mla/blob/master/CONTRIBUTING.md
[3]: https://github.com/kubermatic/mla/releases
[4]: https://github.com/kubermatic/mla/blob/master/CODE_OF_CONDUCT.md

[10]: https://docs.kubermatic.com/
[11]: https://groups.google.com/forum/#!forum/kubermatic-dev
[12]: https://kubermatic.slack.com/messages/kubermatic
[13]: https://github.com/kubermatic/mla/blob/master/Zenhub.md
[15]: http://slack.kubermatic.io/

[20]: https://docs.kubermatic.com/kubermatic/master/architecture/monitoring_logging_alerting/user_cluster/
[21]: https://docs.kubermatic.com/kubermatic/master/guides/monitoring_logging_alerting/user_cluster/admin_guide/
[22]: https://docs.kubermatic.com/kubermatic/master/guides/monitoring_logging_alerting/user_cluster/user_guide/
