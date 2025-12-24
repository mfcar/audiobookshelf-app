//
//  PlayerTimeUtilsTests.swift
//  AudiobookshelfUnitTests
//
//  Created by Ron Heft on 9/20/22.
//

import Foundation
import Testing
@testable import Audiobookshelf

@Suite("PlayerTimeUtils.calcSeekBackTime")
struct CalcSeekBackTimeTests {
  let currentTime: Double = 1000
  
  @Test("Nil lastPlayedMs → should seek back 5s")
  func nilLastPlayerMs() {
    #expect(PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: nil) == 1000)
  }
  
  @Test("Played ~2s ago (<6s) → should seek back 2s")
  func playedLessThan6SecondsAgo() {
    let played2sAgo = Date(timeIntervalSinceNow: -2).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: played2sAgo)
    
    #expect(result == 1000)
  }
  
  @Test("Played ~12s ago (6-12s range) → should seek back 10s")
  func playedBetween6And12SecondsAgo() {
    let played12sAgo = Date(timeIntervalSinceNow: -12).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: played12sAgo)
    
    #expect(result == 997)
  }
  
  @Test("Played ~62s ago (12-30s range) → should seek back 15s")
  func playedBetween12And30SecondsAgo() {
    let played62sAgo = Date(timeIntervalSinceNow: -62).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: played62sAgo)
    
    #expect(result == 990)
  }
  
  @Test("Played ~302s ago (30-180s range) → should seek back 20s")
  func playedBetween30And180SecondsAgo() {
    let played302sAgo = Date(timeIntervalSinceNow: -302).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: played302sAgo)
    
    #expect(result == 980)
  }
  
  @Test("Played ~1802s ago (180-3600s range) → should seek back 25s")
  func playedBetween180And3600SecondsAgo() {
    let played1802sAgo = Date(timeIntervalSinceNow: -1802).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: played1802sAgo)
    
    #expect(result == 970)
  }
  
  @Test("Edge case where currentTime is small and would go negative")
  func edgeCaseCurrentTimeSmall() {
    let played1802sAgo = Date(timeIntervalSinceNow: -1802).timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: 1, lastPlayedMs: played1802sAgo)
    
    #expect(result == 0)
  }
  
  @Test("Edge case: negative lastPlayedMs (should be treated as an old timestamp)")
  func edgeCaseNegativeLastPlayedMs() {
    #expect(PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: -5000) == 970)
  }
  
  @Test("Zero currentTime with old lastPlayedMs returns 0")
  func calcSeekBackTimeWithZeroCurrentTime() {
    let currentTime: Double = 0
    let threeHundredSecondsAgo = Date(timeIntervalSinceNow: -300)
    let lastPlayedMs = threeHundredSecondsAgo.timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.calcSeekBackTime(currentTime: currentTime, lastPlayedMs: lastPlayedMs)
    
    #expect(result == 0)
  }
}

@Suite("PlayerTimeUtils.timeSinceLastPlayed")
struct TimeSinceLastPlayedTests {
  
  @Test("Returns time interval since last player")
  func returnsCorrectInterval() {
    let fiveSecondsAgo = Date(timeIntervalSinceNow: -5)
    let lastPlayedMs = fiveSecondsAgo.timeIntervalSince1970 * 1000
    let result = PlayerTimeUtils.timeSinceLastPlayed(lastPlayedMs)
    
    #expect(result != nil)
    #expect(abs(result! - 5.0) < 1.0, "Expected ~5.0 seconds, got \(result!)")
  }
  
  @Test("Returns nil for nil input")
  func returnsNilForNilInput() {
    #expect(PlayerTimeUtils.timeSinceLastPlayed(nil) == nil)
  }
}

@Suite("PlayerTimeUtils.timeToSeekBackForSinceLastPlayed")
struct TimeToSeekBackForSinceLastPlayedTests {
  
  @Test("Seeks back 0 seconds for nil")
  func nilReturnsZero() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(nil) == 0)
  }
  
  @Test("Seeks back 0 seconds for less than 10 seconds")
  func lessThan10SecondsReturnsZero() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(5.0) == 0)
  }
  
  @Test("Seeks back 3 seconds for less than 1 minute")
  func lessThan1MinuteReturns3Seconds() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(11) == 3)
  }
  
  @Test("Seeks back 10 seconds for less than 5 minutes")
  func lessThan5MinutesReturns10Seconds() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(298) == 10)
  }
  
  @Test("Seeks back 20 seconds for less than 30 minutes")
  func lessThan30MinutesReturns20Seconds() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(1798) == 20)
  }
  
  @Test("Seeks back 30 seconds for greater than 30 minutes")
  func greaterThan30MinutesReturns30Seconds() {
    #expect(PlayerTimeUtils.timeToSeekBackForSinceLastPlayed(3599) == 30)
  }
}
