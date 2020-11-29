# GitHub Traffic

It's a Shell script that extracts traffic metrics from a list of public Git repositories hosted on GitHub.

The script reads a file named `repositories.txt` with usernames and repository names then sends HTTP requests to [GitHub API V3](https://developer.github.com/v3/repos/traffic/) to retrieve the traffic data. All data retrieved is persisted inside the folder `data` in JSON files.

## How to run

| Description | Command |
| :--- | :--- |
| Run script | `./traffic.sh <token>` |
| Run tests | `./traffic_test.sh` |

## Configuration

To extract traffic from the repositories `hello_world`, `java-playground`, `my-project-1` and `ProjectMVP` from the account with username `johnsmith`, the `repositories.txt` should be:

```text
johnsmith hello_world
johnsmith java-playground
johnsmith my-project-1
johnsmith ProjectMVP
```

And the expected content from `data/` directory should be:

```text
data/
├── johnsmith_hello_word
│   └── 2020-11-28 22_33_08_clones.json
│   └── 2020-11-28 22_33_08_popular_paths.json
│   └── 2020-11-28 22_33_08_popular_referrers.json
│   └── 2020-11-28 22_33_08_views.json
├── johnsmith_java-playground
│   └── 2020-11-28 22_33_08_clones.json
│   └── 2020-11-28 22_33_08_popular_paths.json
│   └── 2020-11-28 22_33_08_popular_referrers.json
│   └── 2020-11-28 22_33_08_views.json
├── johnsmith_my-project-1
│   └── 2020-11-28 22_33_08_clones.json
│   └── 2020-11-28 22_33_08_popular_paths.json
│   └── 2020-11-28 22_33_08_popular_referrers.json
│   └── 2020-11-28 22_33_08_views.json
└── johnsmith_ProjectMVP
    └── 2020-11-28 22_33_08_clones.json
    └── 2020-11-28 22_33_08_popular_paths.json
    └── 2020-11-28 22_33_08_popular_referrers.json
    └── 2020-11-28 22_33_08_views.json
```

## Preview

Example of clones:

```json
{
  "count": 9,
  "uniques": 9,
  "clones": [
    {
      "timestamp": "2020-11-23T00:00:00Z",
      "count": 6,
      "uniques": 6
    },
    {
      "timestamp": "2020-11-24T00:00:00Z",
      "count": 3,
      "uniques": 3
    }
  ]
}
```

Example of popular paths:

```json
[
  {
    "path": "/johnsmith/java-playground",
    "title": "johnsmith/java-playground: My first repository",
    "count": 8,
    "uniques": 4
  },
  {
    "path": "/johnsmith/java-playground/tree/master/Main.java",
    "title": "java-playground/Main.java at master · johnsmith...",
    "count": 3,
    "uniques": 1
  }
]
```

Example of popular referrers:

```json
[
  {
    "referrer": "github.com",
    "count": 5,
    "uniques": 4
  }
]
```

Example of views:

```json
{
  "count": 17,
  "uniques": 4,
  "views": [
    {
      "timestamp": "2020-11-23T00:00:00Z",
      "count": 15,
      "uniques": 3
    },
    {
      "timestamp": "2020-11-24T00:00:00Z",
      "count": 2,
      "uniques": 2
    }
  ]
}
```
