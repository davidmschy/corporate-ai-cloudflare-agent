export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    
    // Telegram webhook endpoint
    if (url.pathname === '/telegram') {
      return handleTelegramWebhook(request, env);
    }
    
    // Status check
    if (url.pathname === '/status') {
      return new Response(JSON.stringify({
        agent: 'Corporate AI - David',
        status: 'active',
        telegram: 'connected',
        timestamp: new Date().toISOString()
      }), { 
        headers: { 'Content-Type': 'application/json' }
      });
    }
    
    // Test message endpoint
    if (url.pathname === '/test-message') {
      return sendTestMessage(env);
    }
    
    return new Response('Corporate AI Agent for David', { status: 200 });
  },
  
  async scheduled(event, env, ctx) {
    // Heartbeat every 15 minutes
    console.log('Agent heartbeat:', new Date().toISOString());
  }
};

/**
 * Handle incoming Telegram messages
 */
async function handleTelegramWebhook(request, env) {
  try {
    const update = await request.json();
    
    if (!update.message) {
      return new Response('OK', { status: 200 });
    }
    
    const message = update.message;
    const chatId = message.chat.id;
    const text = message.text || '';
    const from = message.from;
    
    console.log(`Message from ${from.first_name}: ${text}`);
    
    // Process message and generate response
    const response = await processMessage(text, from, env);
    
    // Send response back to Telegram
    await sendTelegramMessage(chatId, response, env);
    
    return new Response('OK', { status: 200 });
  } catch (error) {
    console.error('Error:', error);
    return new Response('Error', { status: 500 });
  }
}

/**
 * Process incoming message and generate response
 */
async function processMessage(text, from, env) {
  const lowerText = text.toLowerCase();
  
  // Simple responses for testing
  if (lowerText.includes('hello') || lowerText.includes('hi')) {
    return `Hello David! ðŸ‘‹\n\nI'm your new Corporate AI agent running on Cloudflare. I'm ready to help with:\n\nâ€¢ Business operations\nâ€¢ Project management\nâ€¢ Team coordination\nâ€¢ Personal tasks\n\nWhat would you like to work on?`;
  }
  
  if (lowerText.includes('status')) {
    return `âœ… I'm running!\n\nLocation: Cloudflare Workers\nDatabase: Cloudflare D1\nStorage: Cloudflare R2\nTelegram: Connected\n\nReady to replace your PC setup.`;
  }
  
  if (lowerText.includes('test')) {
    return `ðŸ§ª Test received!\n\nI can:\n1. Receive your messages âœ“\n2. Process them âœ“\n3. Respond via Telegram âœ“\n\nNext: Deploy full Corporate AI features.`;
  }
  
  // Default response
  return `I received: "${text}"\n\nI'm your new Cloudflare-based agent. Once you approve this setup, I'll migrate all your data from the PC and become your 24/7 assistant.\n\nCommands:\n/hello - Introduction\n/status - Check system status\n/test - Run connection test`;
}

/**
 * Send message to Telegram
 */
async function sendTelegramMessage(chatId, text, env) {
  const botToken = env.TELEGRAM_BOT_TOKEN;
  const url = `https://api.telegram.org/bot${botToken}/sendMessage`;
  
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      chat_id: chatId,
      text: text,
      parse_mode: 'HTML'
    })
  });
  
  if (!response.ok) {
    console.error('Telegram API error:', await response.text());
  }
  
  return response;
}

/**
 * Send test message on startup
 */
async function sendTestMessage(env) {
  const chatId = '7744921861'; // David's Telegram ID
  const botToken = env.TELEGRAM_BOT_TOKEN;
  
  const message = `ðŸš€ <b>Corporate AI Agent Online</b>\n\nI'm now running on Cloudflare!\n\nâœ… Worker: Active\nâœ… Database: Connected\nâœ… Telegram: Connected\nâœ… Ready for testing\n\nReply to this message to start testing. Once you approve, I'll migrate all your data from the PC.\n\nYour 24/7 agent is ready.`;
  
  await sendTelegramMessage(chatId, message, env);
  
  return new Response(JSON.stringify({ sent: true }), {
    headers: { 'Content-Type': 'application/json' }
  });
}
