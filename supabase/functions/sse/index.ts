// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
// / <reference types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts" />
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  const input =
    `In the heart of a bustling city, there stood a quaint bookstore with creaky wooden floors and shelves stacked high with stories waiting to be discovered. It was run by an elderly gentleman named Mr. Emerson, whose love for books was surpassed only by his love for sharing them.

  One rainy afternoon, a young girl named Lily stumbled upon the bookstore, seeking refuge from the downpour outside. Intrigued by the rows of books, she wandered through the aisles until she found herself in front of a dusty old tome titled "The Secret Garden."
  
  Mr. Emerson noticed her fascination and struck up a conversation, sharing his own memories of the book and its magical tale of hidden wonders. Lily's eyes sparkled with excitement as he described the enchanting adventures within its pages.
  
  Inspired by Mr. Emerson's passion, Lily purchased the book and rushed home to begin her own journey into its world of mystery and imagination. Little did she know, the story would not only captivate her mind but also plant the seeds of curiosity and adventure that would blossom within her for years to come.
  
  And so, in that small bookstore on a rainy day, a lifelong love affair with literature was born.`;

  try {
    const headers = new Headers({
      "Content-Type": "text/event-stream",
      Connection: "keep-alive",
      ...corsHeaders,
    });
    // Create a stream
    const stream = new ReadableStream({
      async start(controller) {
        const encoder = new TextEncoder();

        for await (const word of input.split(" ")) {
          const delay = Math.random() * 100;
          await new Promise((resolve) => setTimeout(resolve, delay));
          controller.enqueue(encoder.encode(word));
        }
        controller.close();
      },
    });

    // Return the stream to the user
    return new Response(stream, {
      headers,
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 400,
    });
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/sse' \
    --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
    --header 'Content-Type: application/json'

*/
