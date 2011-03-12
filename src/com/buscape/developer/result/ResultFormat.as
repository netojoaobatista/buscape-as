package com.buscape.developer.result {
	/**
	 * Format of API call response.
	 * 
	 * @author neto
	 */
	public final class ResultFormat {
		/**
		 * JSON format
		 */
		public static const JSON :ResultFormat = new ResultFormat( 'json' );
		
		/**
		 * XML format
		 */
		public static const XML :ResultFormat = new ResultFormat( 'xml' );
		
		private var format :String;
		
		public function ResultFormat( format :String ) {
			switch ( format ) {
				case 'json':
				case 'xml':
					this.format = format;
					break;
				default:
					throw new Error( 'Formato inválido' );
			}
		}
		
		/**
		 * Returns the string representation of ResultFormat
		 */
		public function toString() :String {
			return this.format;
		}
	}
}