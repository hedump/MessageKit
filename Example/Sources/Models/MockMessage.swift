// MIT License
//
// Copyright (c) 2017-2019 MessageKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import AVFoundation
import CoreLocation
import Foundation
import MessageKit
import UIKit

// MARK: - CoordinateItem

private struct CoordinateItem: LocationItem {
  var location: CLLocation
  var size: CGSize

  init(location: CLLocation) {
    self.location = location
    size = CGSize(width: 240, height: 240)
  }
}

// MARK: - ImageMediaItem

private struct ImageMediaItem: MediaItem {
  var text: String?
  var url: URL?
  var image: UIImage?
  var placeholderImage: UIImage
  var size: CGSize

  init(image: UIImage) {
    self.image = image
    size = CGSize(width: 240, height: 240)
    placeholderImage = UIImage()
  }

  init(imageURL: URL) {
    url = imageURL
    size = CGSize(width: 240, height: 240)
    placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
  }
}

// MARK: - MockAudioItem

private struct MockAudioItem: AudioItem {
  var url: URL
  var size: CGSize
  var duration: Float

  init(url: URL) {
    self.url = url
    size = CGSize(width: 160, height: 35)
    // compute duration
    let audioAsset = AVURLAsset(url: url)
    duration = Float(CMTimeGetSeconds(audioAsset.duration))
  }
}

// MARK: - MockContactItem

struct MockContactItem: ContactItem {
  var displayName: String
  var initials: String
  var phoneNumbers: [String]
  var emails: [String]

  init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
    displayName = name
    self.initials = initials
    self.phoneNumbers = phoneNumbers
    self.emails = emails
  }
}

// MARK: - MockLinkItem

struct MockLinkItem: LinkItem {
  let text: String?
  let attributedText: NSAttributedString?
  let url: URL
  let title: String?
  let teaser: String
  let thumbnailImage: UIImage
}

// MARK: - MockMessage

internal struct MockMessage: MessageType {
  // MARK: Lifecycle

    private init(kind: MessageKind, user: MockUser, messageId: String, date: Date, text: String = "") {
    self.kind = kind
    self.user = user
    self.messageId = messageId
    sentDate = date
  }

  init(custom: Any?, user: MockUser, messageId: String, date: Date, text: String = "") {
      self.init(kind: .custom(custom), user: user, messageId: messageId, date: date, text: text)
  }

  init(text: String, user: MockUser, messageId: String, date: Date) {
      self.init(kind: .text(text), user: user, messageId: messageId, date: date, text: text)
  }

  init(attributedText: NSAttributedString, user: MockUser, messageId: String, date: Date, text: String = "") {
      self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date, text: text)
  }

  init(image: UIImage, user: MockUser, messageId: String, date: Date, text: String = "") {
    var mediaItem = ImageMediaItem(image: image)
      mediaItem.text = text
      self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, text: text)
  }

  init(imageURL: URL, user: MockUser, messageId: String, date: Date, text: String = "") {
    var mediaItem = ImageMediaItem(imageURL: imageURL)
      mediaItem.text = text
      self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, text: text)
  }

  init(thumbnail: UIImage, user: MockUser, messageId: String, date: Date, text: String = "") {
    let mediaItem = ImageMediaItem(image: thumbnail)
      self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date, text: text)
  }

  init(location: CLLocation, user: MockUser, messageId: String, date: Date, text: String = "") {
    let locationItem = CoordinateItem(location: location)
      self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date, text: text)
  }

  init(emoji: String, user: MockUser, messageId: String, date: Date, text: String = "") {
      self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date, text: text)
  }

    init(audioURL: URL, user: MockUser, messageId: String, date: Date, text: String = "") {
    let audioItem = MockAudioItem(url: audioURL)
      self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date, text: text)
  }

    init(contact: MockContactItem, user: MockUser, messageId: String, date: Date, text: String = "") {
      self.init(kind: .contact(contact), user: user, messageId: messageId, date: date, text: text)
  }

    init(linkItem: LinkItem, user: MockUser, messageId: String, date: Date, text: String = "") {
      self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date, text: text)
  }

  // MARK: Internal

  var messageId: String
  var sentDate: Date
  var kind: MessageKind

  var user: MockUser

  var sender: SenderType {
    user
  }
}
