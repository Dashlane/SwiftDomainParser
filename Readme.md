# Domain Parser
![Platforms](https://img.shields.io/badge/Platforms-iOS_macOS-blue.svg?style=flat)
[![License](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://github.com/Dashlane/SwiftDomainParser/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift_Package_Manager-compatible-4BC51D.svg?style=flat)](https://www.swift.org/package-manager/)


A full-Swift simple library which allows the parsing of hostnames, using the [Public Suffix List](https://publicsuffix.org).

This Library allows finding the ***domain name*** and the ***public suffix*** / ***top-level-domain*** for a given URL. 


## What is the Public Suffix List ?

The PSL lists all the known public suffixes (like: `com`, `co.uk`, `nt.edu.au`, ...). 
Without this information we are not able to determine which part of a URL is the domain, since a suffix can have more than one Label. A suffix rule may also contain wildcards or exceptions to wildcards. If you want to understand the full format of PSL matching rules, you can read their specification [here](https://github.com/publicsuffix/list/wiki/Format#format).

The PSL is continuously updated.

The list includes ICANN suffixes (official top level domains) but also private suffixes (like `us-east-1.amazonaws.com`).

Examples: 

| URL host                   | Domain          | Public suffix | Matched PSL rule | Explanation    |
|---------------------------:|:---------------:|:-------------:|:----------------:|:---------------|
| `auth.impala.dashlane.com` | `dashlane.com`  | `com`         | `com`            | Simple rule    |
| `sub.domain.co.uk`         | `domain.co.uk`  | `co.uk`       | `co.uk`          | Simple rule    |
| `sub.domain.gov.ck`        | `domain.gov.ck` | `gov.ck`      | `*.ck`           | Wildcard rule  |
| `sub.domain.any.ck`        | `domain.any.ck` | `any.ck`      | `*.ck`           | Wildcard rule  |
| `sub.sub.domain.any.ck`    | `domain.any.ck` | `any.ck`      | `*.ck`           | Wildcard rule  |
| `www.ck`                   | `www.ck`        | `ck`          | `!www.ck`        | Exception rule |
| `sub.www.ck`               | `www.ck`        | `ck`          | `!www.ck`        | Exception rule |
| `sub.sub.www.ck`           | `www.ck`        | `ck`          | `!www.ck`        | Exception rule |


## Usage 

#### Initialization: 
```
import DomainParser
...
let domainParser = try DomainParser()
```

You should use the same instance when you parse multiple URL hosts.

``` 
let domain: String? = domainParser.parse(host: "awesome.dashlane.com")?.domain
print(domain ?? "N/A") // dashlane.com
```

``` 
let suffix1: String? = domainParser.parse(host: "awesome.dashlane.com")?.publicSuffix
print(suffix1 ?? "N/A") // com

let suffix2: String? = domainParser.parse(host: "awesome.dashlane.co.uk")?.publicSuffix
print(suffix2 ?? "N/A") // co.uk
```

## Update the local Public Suffix List 

The local PSL used by the library is located at `DomainParser/DomainParser/Resources/public_suffix_list.dat`.

To update it, run this Terminal command in the `script` folder: 
``` 
swift UpdatePSL.swift 
```


