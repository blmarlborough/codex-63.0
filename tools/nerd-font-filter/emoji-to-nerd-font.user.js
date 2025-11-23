// ==UserScript==
// @name         Claude Code Emoji → Nerd Font Icons
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Replace Claude's emoji with proper Nerd Font icons
// @match        https://claude.ai/*
// @match        https://*.claude.ai/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Emoji → Nerd Font icon mapping
    const EMOJI_MAP = {
        // Checkmarks and X marks
        '✅': '', // CHECKMARK
        '❌': '', // RED-X
        '✓': '',  // plain checkmark → Nerd Font checkmark
        '✗': '',  // plain X → Nerd Font X

        // Task completion
        '☑': '󰄵', // TASK-COMPLETE
        '☐': '', // TASK-INCOMPLETE
        '□': '', // empty box → task incomplete

        // Info markers
        '⭐': '󰓎', // STAR-KEY-INFO
        'ℹ️': '', // GEN-INFO
        'ℹ': '',  // plain info symbol

        // Warnings
        '⚠️': '', // CAUTION
        '⚠': '',  // plain warning
        '🚨': '󰝧', // AGENT-RISK (severe regression)
        '🔴': '󰝧', // red circle → agent risk
    };

    // Create regex from emoji map keys (escape special regex chars)
    const emojiPattern = Object.keys(EMOJI_MAP)
        .map(e => e.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
        .join('|');
    const emojiRegex = new RegExp(emojiPattern, 'g');

    // Replace function
    function replaceEmoji(text) {
        if (!text || typeof text !== 'string') return text;
        return text.replace(emojiRegex, match => EMOJI_MAP[match] || match);
    }

    // Mutation observer to catch dynamically added content
    const observer = new MutationObserver((mutations) => {
        mutations.forEach((mutation) => {
            mutation.addedNodes.forEach((node) => {
                if (node.nodeType === Node.TEXT_NODE && node.textContent) {
                    const replaced = replaceEmoji(node.textContent);
                    if (replaced !== node.textContent) {
                        node.textContent = replaced;
                    }
                } else if (node.nodeType === Node.ELEMENT_NODE) {
                    // Process text nodes within the element
                    const walker = document.createTreeWalker(
                        node,
                        NodeFilter.SHOW_TEXT,
                        null,
                        false
                    );

                    let textNode;
                    while (textNode = walker.nextNode()) {
                        const replaced = replaceEmoji(textNode.textContent);
                        if (replaced !== textNode.textContent) {
                            textNode.textContent = replaced;
                        }
                    }
                }
            });
        });
    });

    // Start observing
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    // Also process existing content on load
    const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );

    let textNode;
    while (textNode = walker.nextNode()) {
        const replaced = replaceEmoji(textNode.textContent);
        if (replaced !== textNode.textContent) {
            textNode.textContent = replaced;
        }
    }

    console.log('[Nerd Font Filter] Emoji replacement active');
})();
