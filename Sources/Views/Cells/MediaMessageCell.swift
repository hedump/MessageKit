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

import UIKit

/// A subclass of `MessageContentCell` used to display video and audio messages.
import UIKit

open class MediaMessageCell: MessageContentCell {
    
    // MARK: - Вложенные в StackView элементы
    
    /// Основное изображение (для фото или видео превью)
    open lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = self.layer.cornerRadius
        return imageView
    }()
    
    /// Текстовая подпись, которая будет располагаться под изображением
    open lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        // По умолчанию можно скрыть, если в большинстве случаев текста нет
        label.isHidden = false
        return label
    }()
    
    // MARK: - Прочие элементы
    
    /// Кнопка проигрывания для видео
    open lazy var playButtonView: PlayButtonView = {
        let playButton = PlayButtonView()
        return playButton
    }()
    
    // MARK: - Stack View
    
    /// Основной вертикальный стек, который будет содержать `imageView` и `captionLabel`
    open lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, captionLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalCentering
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Lifecycle
    
    open override func setupSubviews() {
        super.setupSubviews()
        
        // Добавляем stackView в контейнер ячейки
        messageContainerView.addSubview(contentStackView)
        
        // Добавляем playButtonView поверх imageView
        imageView.addSubview(playButtonView)
        
        captionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        captionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        captionLabel.text = nil
        captionLabel.isHidden = true
        playButtonView.isHidden = true
    }
    
    // MARK: - Constraints
    
    open func setupConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        playButtonView.translatesAutoresizingMaskIntoConstraints = false
        
        // Растягиваем stackView на весь размер контейнера
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: messageContainerView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor)
        ])
        
        // Центрируем playButtonView внутри imageView
        NSLayoutConstraint.activate([
            playButtonView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playButtonView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            playButtonView.widthAnchor.constraint(equalToConstant: 35),
            playButtonView.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    // MARK: - Configure
    
    open override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView
    ) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        // Определяем, есть ли у сообщения подпись
        var captionText: String?
        
        switch message.kind {
        case .photo(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = true
            captionText = mediaItem.text
        case .video(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = false
        default:
            break
        }
        
        // Если есть текст, показываем captionLabel; если нет — скрываем
        if let text = captionText, !text.isEmpty {
            captionLabel.text = text
            captionLabel.isHidden = false
            imageView.layer.cornerRadius = 8
            contentStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        } else {
            captionLabel.text = nil
            captionLabel.isHidden = true
            imageView.layer.cornerRadius = 0
            contentStackView.layoutMargins = .zero
        }
        
        // Вызываем метод делегата, чтобы дать возможность кастомизировать изображение
        displayDelegate.configureMediaMessageImageView(
            imageView,
            for: message,
            at: indexPath,
            in: messagesCollectionView
        )
    }
    
    // MARK: - Gesture
    
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: imageView)
        
        guard imageView.frame.contains(touchLocation) else {
            super.handleTapGesture(gesture)
            return
        }
        
        delegate?.didTapImage(in: self)
    }
}
