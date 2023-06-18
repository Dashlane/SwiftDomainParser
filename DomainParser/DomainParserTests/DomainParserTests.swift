//
//  DomainParserTests.swift
//  DomainParserTests
//
//  Created by Jason Akakpo on 18/07/2018.
//  Copyright © 2018 Dashlane. All rights reserved.
//

import XCTest
@testable import DomainParser

class DomainParserTests: XCTestCase {

    var domainParser: DomainParser!
    override func setUp() {
        super.setUp()
        domainParser = try! DomainParser()
    }

    func testMeasureSetupTime() {
        self.measure {
            _ = try! DomainParser()
        }
    }
    
    func testMeasureParser() {
        self.measure {
            testPSL()
        }
    }
    

    /// Common PSL Unit test. For a given host check if it returns the expected registrable domain
    /// Source: https://raw.githubusercontent.com/publicsuffix/list/master/tests/test_psl.txt
    func testPSL() {

        // nil input.
        checkPublicSuffix(nil, nil)
        // Mixed case.
        checkPublicSuffix("COM", nil)
        checkPublicSuffix("example.COM", "example.com")
        checkPublicSuffix("WwW.example.COM", "example.com")
        // Leading dot.
        // Listed, but non-Internet, TLD.
        //checkPublicSuffix("local", nil);
        //checkPublicSuffix("example.local", nil);
        //checkPublicSuffix("b.example.local", nil);
        //checkPublicSuffix("a.b.example.local", nil);
        // TLD with only 1 rule.
        checkPublicSuffix("biz", nil)
        checkPublicSuffix("domain.biz", "domain.biz")
        checkPublicSuffix("b.domain.biz", "domain.biz")
        checkPublicSuffix("a.b.domain.biz", "domain.biz")
        // TLD with some 2-level rules.
        checkPublicSuffix("com", nil)
        checkPublicSuffix("example.com", "example.com")
        checkPublicSuffix("b.example.com", "example.com")
        checkPublicSuffix("a.b.example.com", "example.com")
        checkPublicSuffix("uk.com", nil)
        checkPublicSuffix("example.uk.com", "example.uk.com")
        checkPublicSuffix("b.example.uk.com", "example.uk.com")
        checkPublicSuffix("a.b.example.uk.com", "example.uk.com")
        checkPublicSuffix("test.ac", "test.ac")
        // TLD with only 1 (wildcard) rule.
        checkPublicSuffix("mm", nil)
        checkPublicSuffix("c.mm", nil)
        checkPublicSuffix("b.c.mm", "b.c.mm")
        checkPublicSuffix("a.b.c.mm", "b.c.mm")
        // More complex TLD.
        checkPublicSuffix("jp", nil)
        checkPublicSuffix("test.jp", "test.jp")
        checkPublicSuffix("www.test.jp", "test.jp")
        checkPublicSuffix("ac.jp", nil)
        checkPublicSuffix("test.ac.jp", "test.ac.jp")
        checkPublicSuffix("www.test.ac.jp", "test.ac.jp")
        checkPublicSuffix("kyoto.jp", nil)
        checkPublicSuffix("test.kyoto.jp", "test.kyoto.jp")
        checkPublicSuffix("ide.kyoto.jp", nil)
        checkPublicSuffix("b.ide.kyoto.jp", "b.ide.kyoto.jp")
        checkPublicSuffix("a.b.ide.kyoto.jp", "b.ide.kyoto.jp")
        checkPublicSuffix("c.kobe.jp", nil)
        checkPublicSuffix("b.c.kobe.jp", "b.c.kobe.jp")
        checkPublicSuffix("a.b.c.kobe.jp", "b.c.kobe.jp")
        checkPublicSuffix("city.kobe.jp", "city.kobe.jp")
        checkPublicSuffix("www.city.kobe.jp", "city.kobe.jp")
        // TLD with a wildcard rule and exceptions.
        checkPublicSuffix("ck", nil)
        checkPublicSuffix("test.ck", nil)
        checkPublicSuffix("b.test.ck", "b.test.ck")
        checkPublicSuffix("a.b.test.ck", "b.test.ck")
        checkPublicSuffix("www.ck", "www.ck")
        checkPublicSuffix("www.www.ck", "www.ck")
        // US K12.
        checkPublicSuffix("us", nil)
        checkPublicSuffix("test.us", "test.us")
        checkPublicSuffix("www.test.us", "test.us")
        checkPublicSuffix("ak.us", nil)
        checkPublicSuffix("test.ak.us", "test.ak.us")
        checkPublicSuffix("www.test.ak.us", "test.ak.us")
        checkPublicSuffix("k12.ak.us", nil)
        checkPublicSuffix("test.k12.ak.us", "test.k12.ak.us")
        checkPublicSuffix("www.test.k12.ak.us", "test.k12.ak.us")
        // IDN labels.
        checkPublicSuffix("食狮.com.cn", "食狮.com.cn")
        checkPublicSuffix("食狮.公司.cn", "食狮.公司.cn")
        checkPublicSuffix("www.食狮.公司.cn", "食狮.公司.cn")
        checkPublicSuffix("shishi.公司.cn", "shishi.公司.cn")
        checkPublicSuffix("公司.cn", nil)
        checkPublicSuffix("食狮.中国", "食狮.中国")
        checkPublicSuffix("www.食狮.中国", "食狮.中国")
        checkPublicSuffix("shishi.中国", "shishi.中国")
        checkPublicSuffix("中国", nil)
        // Same as above, but punycoded. This Library does not support punyCoded URLs.
        //        checkPublicSuffix("xn--85x722f.com.cn", "xn--85x722f.com.cn");
        //        checkPublicSuffix("xn--85x722f.xn--55qx5d.cn", "xn--85x722f.xn--55qx5d.cn");
        //        checkPublicSuffix("www.xn--85x722f.xn--55qx5d.cn", "xn--85x722f.xn--55qx5d.cn");
        //        checkPublicSuffix("shishi.xn--55qx5d.cn", "shishi.xn--55qx5d.cn");
        //        checkPublicSuffix("xn--55qx5d.cn", nil);
        //        checkPublicSuffix("xn--85x722f.xn--fiqs8s", "xn--85x722f.xn--fiqs8s");
        //        checkPublicSuffix("www.xn--85x722f.xn--fiqs8s", "xn--85x722f.xn--fiqs8s");
        //        checkPublicSuffix("shishi.xn--fiqs8s", "shishi.xn--fiqs8s");
        //        checkPublicSuffix("xn--fiqs8s", nil);

    }

    func checkPublicSuffix(_ host: String?,
                           _ expectedDomain: String?,
                           file: StaticString = #file,
                           line: UInt = #line) {
        guard let host = host else { return }
        XCTAssertEqual(domainParser.parse(host: host.lowercased())?.domain, expectedDomain, file: file, line: line)
    }


    func testWildcardRulesSorting() {
        // From https://github.com/publicsuffix/list/wiki/Format#example
        let rulesArray = [
            "com",
            "*.jp",
            "*.hokkaido.jp",
            "*.tokyo.jp",
            "!pref.hokkaido.jp",
            "!metro.tokyo.jp",
        ]

        let rulesText = rulesArray.joined(separator: "\n")
        let rulesData = rulesText.data(using: .utf8)!
        let customDomainParser = try! DomainParser.init(rulesData: rulesData)

        // Just checking that we are using a custom suffix rule set. This would be a valid domain normally.
        XCTAssertNil(customDomainParser.parse(host: "google.fr")?.domain)


        // From https://github.com/publicsuffix/list/wiki/Format#example

        // Cookies may be set for foo.com. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "foo.com")?.domain, "foo.com")

        // Cookies may be set for foo.bar.jp. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "foo.bar.jp")?.domain, "foo.bar.jp")

        // Cookies may *not* be set for bar.jp. (not valid domain)
        XCTAssertNil(customDomainParser.parse(host: "bar.jp")?.domain)

        // Cookies may be set for foo.bar.hokkaido.jp. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "foo.bar.hokkaido.jp")?.domain, "foo.bar.hokkaido.jp")

        // Cookies may *not* be set for bar.hokkaido.jp. (not valid domain)
        XCTAssertNil(customDomainParser.parse(host: "bar.hokkaido.jp")?.domain)

        // Cookies may be set for foo.bar.tokyo.jp. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "foo.bar.tokyo.jp")?.domain, "foo.bar.tokyo.jp")

        // Cookies may *not* be set for bar.tokyo.jp. (not valid domain)
        XCTAssertNil(customDomainParser.parse(host: "bar.tokyo.jp")?.domain)
        
        // Cookies may be set for pref.hokkaido.jp because the exception overrides the previous rule. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "pref.hokkaido.jp")?.domain, "pref.hokkaido.jp")

        // Cookies may be set for metro.tokyo.jp, because the exception overrides the previous rule. (valid domain)
        XCTAssertEqual(customDomainParser.parse(host: "metro.tokyo.jp")?.domain, "metro.tokyo.jp")
    }
}

