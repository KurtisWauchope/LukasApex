global class V11_scheduleComarchImport {

    public void scheduleImports() {
        string test1 = '';
        if(Test.isRunningTest()){
            test1 = ' Test';
        }

        System.schedule('Quote 1'+test1, '0 0 * * * ?', new V11_scheduleQuoteImport());
        System.schedule('Quote 2'+test1, '0 15 * * * ?', new V11_scheduleQuoteImport());
        System.schedule('Quote 3'+test1, '0 30 * * * ?', new V11_scheduleQuoteImport());
        System.schedule('Quote 4'+test1, '0 45 * * * ?', new V11_scheduleQuoteImport());

        System.schedule('Order 1'+test1, '0 5 * * * ?', new V11_scheduleOrderImport());
        System.schedule('Order 2'+test1, '0 20 * * * ?', new V11_scheduleOrderImport());
        System.schedule('Order 3'+test1, '0 35 * * * ?', new V11_scheduleOrderImport());
        System.schedule('Order 4'+test1, '0 50 * * * ?', new V11_scheduleOrderImport());

        System.schedule('Account 1'+test1, '0 10 * * * ?', new V11_scheduleAccountImport());
        System.schedule('Account 2'+test1, '0 40 * * * ?', new V11_scheduleAccountImport());

        System.schedule('Product'+test1, '0 0 22 * * ? *', new V11_scheduleProductImport());
        System.schedule('Entity Extensions'+test1, '0 0 21 * * ? *', new V11_scheduleEntityExtensionImport());

    }
}