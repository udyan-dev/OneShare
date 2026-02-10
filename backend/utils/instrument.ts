if (process.env.NODE_ENV === 'production') {
    const trace = await import('@google-cloud/trace-agent');
    trace.start();
}
